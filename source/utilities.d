module utilities;

import core.stdc.stdlib;
import std.stdio;

void showHelp()
{
    // Help text
    writeln("DSSG - A static site generator written in D");
    writeln("");
    writeln("Usage:");
    writeln("  dssg new <project_name>  Create a new DSSG project");
    writeln("  dssg build               Build a DSSG project");
    writeln("  dssg serve [<port>]      Serve DSSG project. Standard port is 4242");
    writeln("  dssg version             Get DSSG version");
    writeln("  dssg help                Read this help text");
}

void exitDssg()
{
    writeln("Build not finished. Exiting...");
    exit(0);
}

void getVersion()
{
    writeln("0.2.0");
}