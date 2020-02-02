module dssg.cli;

import core.exception;
import dssg.core;
import dssg.messages;
import dssg.server;
import dssg.sharedvalues;
import dssg.utilities;
import std.conv;
import std.format;
import std.stdio;

void handleCli(string[] args)
{
    try
    {
        switch (args[1])
        {
            case "new":
                if (args.length == 3)
                {
                    createProject(args[2]);
                    break;
                }
                else
                {
                    writeln(invalidAmountErr);
                    break;
                }
            case "build":
                if (args.length == 2)
                {
                    buildProject;
                    break;
                }
                else
                {
                    writeln(invalidAmountErr);
                    break;
                }
            case "serve":
                if (args.length == 2)
                {
                    serveProject(port);
                    break;
                }
                if (args.length == 3)
                {
                    try
                    {
                        port = to!ushort(args[2]);
                        serveProject(port);
                        break;
                    }
                    catch (ConvException e)
                    {
                        writeln(format(invalidTypeErr, args[2]));
                        break;
                    }
                }
                else
                {
                    writeln(invalidAmountErr);
                    break;
                }
            case "version":
                if (args.length == 2)
                {
                    getVersion;
                    break;
                }
                else
                {
                    writeln(invalidAmountErr);
                    break;
                }
            case "help":
                if (args.length == 2)
                {
                    showHelp;
                    break;
                }
                else
                {
                    writeln(invalidAmountErr);
                    break;
                }
            default: writeln(invalidArgumentErr);
        }
    }
    catch (RangeError e)
    {
        writeln(invalidArgumentErr);
    }
}