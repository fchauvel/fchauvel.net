+++
banner = ""
categories = []
date = "2016-08-28T07:38:22+02:00"
description = ""
images = []
menu = ""
tags = ["gandi.net", "lftp", "codeship.io"]
title = "How to Automatically Deploy on Gandi?"
draft = "true"
+++

fchauvel.net&mdash;this very website&mdash;is built with
[Hugo](http://gohugo.io) and hosted by
[Gandi.net](http://gandi.net). I explain below several strategy to
automate the deployment ono Gandi's simple hosting solution.

## Gandi.net Simple Hosting

Gandi offers several hosting solutions, among which is the *simple
hosting* that I use. Unfortunately, Gandi restrict access to SFTP or
SSH, but the SSH console has first to be activated on the Gandi portal
and remains available for only two hours. `rsync`, `scp` and the likes
are not supported. So, here are the two steps I use to overcome these
restrictions:

1. __Register your public SSH-RSA key to the Gandi portal.__ If
the Gandi.net portal rejects your key&mdash; as it does to mine&mdash;
you can still manually edit the `.ssh/authorized_keys` in a SFTP
session open with login and password.

2. __Use `lftp` to automatically synchronise your
content.__ [`lftp`](https://lftp.yar.ru/) is a very powerful FTP client,
that supports many protocols, and above all, is scriptable. Here is
the script I use:

 ````
 #!/usr/bash -f
 echo "
 set sftp:connect-program 'ssh -a -x -i $PATH_TO_PRIVATE_KEY';
 open -u $GANDI_LOGIN,xxx sftp://sftp.dc0.gpaas.net;
 mirror -c -e -R $LOCAL_CONTENT $REMOTE_CONTENT" > upload_script.txt
 lftp -f upload_script.txt 
 ````
A couple of explanation, though:
 
* Here, `$PATH_PRIVATE_KEY` must be replaced by the path to your SSH
  private key.

* `$GANDI_LOGIN` stands for your user login (e.g., 123456). It appears
  on the Gandi portal, when place your mouse on a small information
  sign, among the credentials.

* Note that you must provide a dummy password, `xxx` in my script, to
avoid LFTP to prompt you forone.

## Continuous Deployment

I actually generate this website using [Hugo](http://gohugo.io) from
Markdown files, which I secure in a dedicated GitHub repository. What
I want is to automate the deployment: When I push some changes to the
content, I want the site to be rebuilt and redeployed, *automatically*.

To do this, one important thing is to install themes as Git submodules,
using:

````
$> cd themes
$> git submodule add https://github.com/me/mytheme.git
````

Then, we must clone the themes when the CI server checkout the
code. Either do `git submodule update --init --recursive` before to
build the website or ensure you make a recursive clone using `git
clone --recursive https://github.com/me/mytheme.git`.


### Using Codeship.io

As explained by [J-C
Lavocat](http://jice.lavocat.name/blog/2015/hugo-deployment-via-codeship/),
Codeship is one solution. He uses `rsync` instead of `lftp` but his
solution works just fine. Here is how I adapted it:

````
# Install Hugo, directly from Github
go get -v -u github.com/spf13/hugo
hugo

# Mirror the content
echo "
open -u $GANDI_LOGIN,xxx sftp://sftp.dc0.gpaas.net;
mirror -c -e -R public $REMOTE_CONTENT" > upload_script.txt
lftp -f upload_script.txt 
```` 

### Using Wercker
The [Hugo's documentation](https://gohugo.io/tutorials/automated-deployments/) recommends using [Wercker](http://wercker.com), but in my view, it is more convoluted. It permits to use a specific version of Hugo, though. Proceed as follows:

1. Register to the Wercker website;
2. Create a `wercker.yml` configuration (see below); 
3. Create a deployment pipeline, and generate a new pair of SSH-KEY to the deploy step;
4. Register your public SSH-RSA key on Gandi.net. (I had to do it manually, by editing the `.ssh/authorized_keys`).

Here is the `wercker.yml` that eventually worked for me, after many
trials and error&mdashI must admit. I adapted [Joseph Stahl's
solution](https://josephstahl.com/blog/2015/04/24/publishing-a-hugo-blog-to-digitalocean-with-wercker/).

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

I adjusted the build phase so that I also clone the themes as
submodules. 