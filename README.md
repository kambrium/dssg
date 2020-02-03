DSSG - A static site generator with a different approach
========================================================

![DSSG logo](dssg-logo.jpg)

[![Build Status](https://travis-ci.org/kambrium/dssg.svg?branch=master)](https://travis-ci.org/kambrium/dssg)

Advantages
----------
Unlike other static site generators, DSSG doesn't differentiate between front matter and a content section in its content files. This makes it very easy to create web pages based on templates with multiple content sections.

For maximum flexibility, each project can be based on multiple templates.

Content may be written in both [Markdown](https://en.wikipedia.org/wiki/Markdown "Markdown") or pure HTML.

How does it work?
-----------------
DSSG creates HTML pages out of [TOML](https://github.com/toml-lang/toml "TOML") files. Each TOML file represents one HTML page and consists of as many key-value pairs as you want.

The key-value pairs contain both metadata and the actual page content. There can be multiple key-value pairs with page content. If a key in your TOML file ends with `_md`, DSSG expects Markdown as value. DSSG will turn the Markdown into HTML.

Templates are written in the [Mustache template language](https://mustache.github.io/ "Mustache template language"). DSSG substitues each variable in the template with its equivalent from the TOML file. 

Why is it called DSSG?
-----------------------
DSSG is written in the [D programming language](https://dlang.org/ "D programming language"). DSSG stands for **D** **S**tatic **S**ite **G**enerator.

Download
--------
The latest binaries are available on [https://github.com/kambrium/dssg/releases](https://github.com/kambrium/dssg/releases "https://github.com/kambrium/dssg/releases"). Currently, there are Ubuntu 16.04 and Windows 10 binaries.

Installation (Linux)
--------------------
1. After you have downloaded the software (see above), open a terminal, change to the directory that contains the DSSG binary and set the permissions so that you can execute the program.

    ```bash
    $ cd /this/is/your/dssg/path/
    $ chmod u+x dssg
    ```

2. Add the directory that contains the DSSG binary to your PATH. Please refer to the documentation of your distribution for further details. Here is an example of how it works on **Ubuntu** with **Bash**.

    ```bash
    $ echo 'export PATH=$PATH:/this/is/your/dssg/path/' >> ~/.bashrc
    $ source ~/.bashrc
    ```

Installation (Windows)
----------------------
1. After you have downloaded the software (see above), open the PowerShell and add the directory that contains the DSSG binary to your Path.

    ```powershell
    PS> [System.Environment]::SetEnvironmentVariable("Path", [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";C:\this\is\your\dssg\path", [EnvironmentVariableTarget]::User)
    ```

2. Restart the PowerShell.

Try the example
---------------

```bash
$ git clone https://github.com/kambrium/dssg-example.git
$ cd dssg-example
$ dssg build
$ dssg serve
```

Begin from scratch
------------------

```bash
$ dssg new myproject
$ cd myproject
// Create Mustache templates in 'contents/_templates'
// Create TOML files, CSS, JavaScript, images etc. in 'contents'
$ dssg build
$ dssg serve
```

Made with DSSG
--------------
- [1572.li](http://1572.li "http://1572.li")

License
-------
MIT