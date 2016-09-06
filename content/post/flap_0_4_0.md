+++
banner = "banner.png"
categories = ["software"]
date = "2016-09-06T10:44:46+02:00"
description = "FLaP v0.4 is Out!"
images = []
menu = ""
tags = ["FLaP"]
title = "FLaP v0.4 is Out!"
draft = "true"
+++

I released yesterday version 0.4 of
[FLaP](http://pythonhosted.org/FLaP/)! It now flattens LaTeX files
included using the [LaTeX subfiles
package](https://www.ctan.org/pkg/subfiles?lang=en). Besides, I fixed
several bugs that had been reported on GitHub, including:

* Fix flattening `\bibliography` stored in a subdirectory
* Fix bug on `\graphicpath` directives using double curly braces (e.g., `\graphicpath{{./img/}}`).
* Fix bugs on `\input` directives:
  * `\input` directives that specify the `.tex` extension are properly handled;
  * Relative paths specified in `\input` are considered from the root directory of the latex project, as LaTeX does.
* Fix for LaTeX commands broken down over multiple lines
* Fix for images whose name conflict once merged

Just let me know your opinion if you give it a try!
