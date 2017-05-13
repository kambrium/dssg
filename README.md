DSSG - A static site generator written in D
===========================================

![DSSG logo](dssg-logo.jpg)

About
-----
DSSG is a static site generator written in the D programming language. It creates HTML pages out of Markdown files and Mustache templates.

Download
--------
The latest binaries are available on [https://github.com/kambrium/dssg/releases](https://github.com/kambrium/dssg/releases "https://github.com/kambrium/dssg/releases"). Currently, there are just Linux binaries.

Installation
------------
Add the directory that contains the DSSG binary to your PATH. For example, on Ubuntu, add the following line to your `.bashrc`.
```
export PATH=$PATH:/this/is/your/dssg/path/
```

Try the Example
---------------
```shell
$ git clone https://github.com/kambrium/dssg-example.git
$ cd dssg-example
$ dssg build
$ firefox build/index.html
```

Begin from Scratch
------------------
```shell
$ dssg new myproject
// Create Markdown files, CSS, JavaScript, images etc. in the directory 'contents', Mustache templates in 'contents/_templates'.
$ dssg build
```

Why?
----
I wanted to get to know the D programming language and needed a substitute for Microsoft's Dynamic Web Templates (used in deprecated Expression Web).

License
-------
MIT