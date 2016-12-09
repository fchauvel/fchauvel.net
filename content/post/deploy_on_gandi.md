+++
banner = "images/code.jpg"
categories = ["sys-admin"]
date = "2016-08-28T07:38:22+02:00"
description = ""
images = []
menu = ""
tags = ["gandi.net"]
title = "How to Automatically Deploy on Gandi?"
+++

I host fchauvel.net (this very website) on
[Gandi.net](http://gandi.net).  I use [Hugo](http://gohugo.io) to
generate it and I explain below how, each time I update its content, I
automatically upload the new website.
 
## Upload to Gandi.net using LFTP

Gandi offers several hosting solutions, from which I have chosen
*simple hosting*. Generally, I use `rsync` or `scp` to upload all my
content in one go, but Gandi restricts access to either SFTP or GIT.

I eventually used `lftp` to automatically synchronise my local content
with my Gandi host. [`lftp`](https://lftp.yar.ru/) is a very powerful
FTP client that supports many protocols, and above all, is
'scriptable'. Here is the script I wrote:

 ````
 #!/usr/bash -f
 echo "
 set sftp:connect-program 'ssh -a -x -i $PATH_TO_PRIVATE_KEY';
 open -u $GANDI_LOGIN,xxx sftp://sftp.dc0.gpaas.net;
 mirror -c -e -R $LOCAL_CONTENT $REMOTE_CONTENT" > upload_script.txt
 lftp -f upload_script.txt 
 ````

A couple of explanations, though:

* `lftp` is available in most Linux repositories. On Debian, I
  installed it using `apt-get install lftp`.
 
* You must replace `$PATH_PRIVATE_KEY` by the path to your own private
  RSA key (on your local machine).  Remember to register the
  associated public key on the Gandi portal. If the Gandi.net
  portal rejects your key&mdash;as it did for mine&mdash;you can still
  manually edit the `.ssh/authorized_keys` in a SFTP session opened
  with login and password (I use
  [WinSCP](https://winscp.net/eng/index.php) in that case).

* `$GANDI_LOGIN` stands for your user login (e.g., 123456). It appears
  on the Gandi portal, when you place your mouse on a small information
  sign next to the SFTP entry.

* You __must__ provide a dummy password (`xxx` in my script) to avoid
  LFTP to prompt you for one. This would make your script hang if you
  use it to automate the upload (as shown below).

* Remember to use the `-d` option of `lftp` to debug issues. I find it
  especially useful to investigate authentication failures.
 

## Store Content on GitHub

I generate this website using [Hugo](http://gohugo.io). Hugo converts
articles written as simple Markdown files into complicated HTML
pages. I secure these Markdown files along with Hugo's configuration
in a dedicated [GitHub
repository](http://github.com/fchauvel/fchauvel.net) and when I push
some changes to GitHub, I want the site to be regenerated and
redeployed, *automatically*.

The trick is to install Hugo's themes as Git submodules. If we do not,
`git` would detect that themes are also GitHub repositories and their
content would be excluded from your repository.  Any clone of your
repository would then lack its themes. To install a theme as a
submodule, I clone it using:

````bash
$> cd themes 
$> git submodule add https://github.com/me/mytheme.git
````

Now, when I checkout my website's sources (say on the continuous
integration server), I must explicitly ask Git to also clone the
submodules (i.e., the themes). I either do `git submodule update
--init --recursive` before to ask Hugo to build the website or I make
a recursive clone using `git clone --recursive
https://github.com/me/mytheme.git`.


## Automate Using Codeship.io

J.C. Lavocat explained [how to automate the deployment of Hugo site
using
Codeship.io](http://jice.lavocat.name/blog/2015/hugo-deployment-via-codeship/). He
uses `rsync` instead of `lftp` but his solution works just fine. Here
is how I adapted it:

````
# Install Hugo, directly from Github
go get -v -u github.com/spf13/hugo
cd ~/clone
hugo

# Mirror the content
echo "
open -u $GANDI_LOGIN,xxx sftp://sftp.dc0.gpaas.net;
mirror -c -e -R public $REMOTE_CONTENT" > upload_script.txt
lftp -f upload_script.txt 
```` 

The downside is that we then automatically fetch the latest
development version of Hugo's sources, instead installing the latest
stable release. From time to time the generation will fail because of
some new and unstable features under development.

## Or Automate Using Wercker

[Hugo's
documentation](https://gohugo.io/tutorials/automated-deployments/)
actually suggests using [Wercker](http://wercker.com). In my view,
it is more convoluted, but it permits specifying a version of
Hugo. I proceed as follows:

1. Register to the Wercker website;
2. Create a `wercker.yml` configuration (see below); 
3. Create a deployment pipeline, and generate a new pair of RSA keys attached to the deploy step;
4. Register your public RSA key on Gandi.net. (I had to do it manually, by editing the `.ssh/authorized_keys`).

Below is the `wercker.yml` that eventually worked for me, after many
trials and errors&mdash;I must admit. I adapted [Joseph Stahl's
solution to deploy on Digital
Ocean](https://josephstahl.com/blog/2015/04/24/publishing-a-hugo-blog-to-digitalocean-with-wercker/). I change two things: 
 
* I adjusted the build phase so that I also clone the themes as
submodules.  
* I do not fetch and store the private key manually, I
use the `add-ssh-key` step instead.

````yml
box: debian
build:
  steps:
    - install-packages:
        packages: git
    - script:
        name: initialize git submodules
        code: |
            git submodule update --init --recursive
    - arjen/hugo-build:
        version: "0.16"
        theme: hugo-icarus-theme
        flags: -v
deploy:
  steps:
    - install-packages:
        packages: openssh-client lftp
    - add-to-known_hosts:
        hostname: sftp.dc0.gpaas.net
    - add-ssh-key:
        keyname: DEPLOY
    - script:
        name: Mirror on gandi.net
        code: |
           echo "
           set sftp:connect-program 'ssh -a -x -i /root/.ssh/config';
           open -u 123456,xxx sftp://sftp.dc0.gpaas.net;
           mirror -c -e -R public your_remote/directory;" > script.txt
           lftp -d -f script.txt
````

