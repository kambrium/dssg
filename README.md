DSSG - A static site generator written in D
===========================================

![DSSG logo](dssg-logo.jpg)

[![Build Status](https://travis-ci.org/kambrium/dssg.svg?branch=master)](https://travis-ci.org/kambrium/dssg)

About
-----
DSSG is a static site generator written in the D programming language. It creates HTML pages out of Markdown files and Mustache templates.

Download
--------
The latest binaries are available on [https://github.com/kambrium/dssg/releases](https://github.com/kambrium/dssg/releases "https://github.com/kambrium/dssg/releases"). Currently, there are just Linux binaries.

Installation
------------
1. After you have downloaded the software (see above), change to the directory that contains the DSSG binary and set the permissions so that you can execute the program.

    ```
    cd /this/is/your/dssg/path/
    chmod u+x dssg
    ```

2. Add the directory that contains the DSSG binary to your PATH. Please refer to the documentation of your distribution for further details. Here is an example of how it works on **Ubuntu** with **Bash**.

    Open your `.bashrc`.

    ```
    vim ~/.bashrc
    ```
    
    Add the following line at the end of your `.bashrc`.

    ```
    export PATH=$PATH:/this/is/your/dssg/path/
    ```

    Source your `.bashrc`.

    ```
    source ~/.bashrc
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