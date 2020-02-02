module dssg.cli;

import core.exception;
import dssg.core;
import dssg.defaults;
import dssg.errormessages;
import dssg.server;
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
                    writeln(invalidAmountError);
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
                    writeln(invalidAmountError);
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
                        writeln(format(invalidTypeError, args[2]));
                        break;
                    }
                }
                else
                {
                    writeln(invalidAmountError);
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
                    writeln(invalidAmountError);
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
                    writeln(invalidAmountError);
                    break;
                }
            default: writeln(invalidArgumentError);
        }
    }
    catch (RangeError e)
    {
        writeln(invalidArgumentError);
    }
}