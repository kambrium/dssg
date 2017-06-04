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
$ dssg serve
```

Begin from Scratch
------------------
```shell
$ dssg new myproject
$ cd myproject
// Create Mustache templates in 'contents/_templates'
// Create Markdown files, CSS, JavaScript, images etc. in 'contents'
$ dssg build
$ dssg serve
```

License
-------
MIT