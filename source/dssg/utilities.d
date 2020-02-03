// Some additional functions that did not fit anywhere else

module dssg.utilities;

import core.stdc.stdlib;
import dssg.messages;
import std.stdio;

void showHelp()
{
    foreach (string value; helpMsg)
    {
        writeln(value);
    }
}

void exitDssg()
{
    writeln(exitingMsg);
    exit(0);
}

void getVersion()
{
    writeln("1.0.0");
}