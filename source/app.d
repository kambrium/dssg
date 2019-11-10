import core.exception;
import core.stdc.stdlib;
import dmarkdown;
import mustache;
import std.algorithm.searching;
import std.array;
import std.conv;
import std.file;
import std.format;
import std.path;
import std.range;
import std.regex;
import std.stdio;
import std.utf;
import toml;
import vibe.core.core : runEventLoop;
import vibe.http.fileserver;
import vibe.http.router;
import vibe.http.server;

// Constants 
enum ver = "0.2.0";

enum contentsRoot = "contents";
enum templatesRoot = buildPath(contentsRoot,"_templates");
enum buildRoot = "build";

enum invalidArgumentError = "ERROR: Invalid argument(s) given. HINT: Enter 'dssg help' for a list of valid arguments.";
enum invalidAmountError = "ERROR: Invalid amount of arguments given. HINT: Enter 'dssg help' for help.";
enum dirStructureError = format("ERROR: Could not find required directories '%s' and/or '%s'. HINT: Create them manually or use 'dssg new <name_of_new_project>'.", contentsRoot, templatesRoot);
enum invalidTypeError = "ERROR: %s is not a valid port number.";
enum createError = "ERROR: %s already exists. Try another name.";
enum deleteError = "ERROR: Could not delete build directory. HINT: Maybe a directory or file in the build directory is in use?";
enum inputFileError = "ERROR: Could not read file '%s'. HINT: Maybe it's not a text file.";
enum templateError = "ERROR: Could not create HTML file '%s'. HINTS: Maybe the template's name specified in frontmatter is not correct. Maybe the default template (template.mustache) doesn't exist.";
enum tomlParserError = "ERROR: Could not parse TOML file '%s'. HINT: Check your TOML syntax.";

ushort port = 4242;


void main(string[] args)
{ 
    // CLI handling
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

void createProject(string projectName)
{
    // Make sure that there is no entry that is called like the new project
    if (!projectName.exists)
    {
        mkdirRecurse(buildPath(projectName, templatesRoot));
    }
    else
    {
        writeln(format(createError, projectName));
    }
}

void buildProject()
{
    // Make sure that required directories exist
    if (templatesRoot.exists)
    {
        writeln("Starting the build process...");

        createBuildRoot;

        // Iterate through all items in contentsRoot
        foreach (DirEntry entry; dirEntries(contentsRoot, SpanMode.breadth))
        {
            // Ignore templatesRoot
            if (!startsWith(entry.name, templatesRoot))
            {
                string path = entry.name;
                path.popFrontExactly(contentsRoot.length+1);

                // Create equivalent directory in build directory
                if (entry.isDir)
                {
                    mkdir(buildPath(buildRoot, path));
                }
                // Process TOML files
                else if (entry.isFile && endsWith(entry.name, ".toml"))
                {
                    processPage(entry.name, path);
                }
                // Just copy all the other files
                else if (entry.isFile)
                {
                    copy(entry.name, buildPath(buildRoot, path));
                }
            }
        }

        writeln("Finished new build.");
    }
    else
    {
        writeln(dirStructureError);
        exitDssg;
    }
}

void createBuildRoot()
{
    // Remove previous build and create new build directory
    try
    {
        if (buildRoot.exists)
        {
            rmdirRecurse(buildRoot);
            writeln("Deleted previous build.");
        }
        mkdir(buildRoot);
    }
    catch (FileException e)
    {
        writeln(deleteError);
        exitDssg;
    }
}

void processPage(string pageName, string path)
{
    // Read input file
    string inputFromFile;
    try
    {
        inputFromFile = readText(pageName);
    }
    catch (UTFException e)
    {
        writeln(format(inputFileError, path));
        exitDssg;
    }

    // TOML parsing
    TOMLDocument tomlFromFile;
    try
    {
        tomlFromFile = parseTOML(inputFromFile);
    }
    catch (TOMLParserException e)
    {
        writeln(format(tomlParserError, path));
        exitDssg;
    }

    // Prepare template context
    alias MustacheEngine!(string) Mustache;
    Mustache mustache;
    auto context = new Mustache.Context;

    string pageTemplate = "template";

    // Iterate through TOMLDocument
    foreach (string key, value; tomlFromFile)
    {
        // Turn TOML value to string and drop quotation marks at the beginning and end of string
        string valueString = value.toString.drop(1).dropBack(1);

        // Unescaping valueString
        immutable string[string] unescapingArray = [
            `\\"`: `"`, /* Raw string required */
            `\\\\`: "\\",
            `\\b`: "\b",
            `\\f`: "\f",
            `\\n`: "\n",
            `\\r`: "\r",
            `\\t`: "\t"
        ];
        foreach (string escapedString, unescapedString; unescapingArray)
        {
            valueString = replaceAll(valueString, regex(escapedString, "g"), unescapedString);
        }

        // Fill the template
        if (key == "template")
        {
            pageTemplate = valueString;
        }
        else if (endsWith(key, "_md"))
        {
            string contentHtml = filterMarkdown(valueString);
            context[key] = contentHtml;
        }
        else
        {
            context[key] = valueString;
        }
    }
    
    // Build paths for rendering and saving
    string templatePath = buildPath(templatesRoot, pageTemplate);
    string htmlPath = buildPath(buildRoot, setExtension(path, "html"));

    // Render and save page
    try
    {
        std.file.write(htmlPath, mustache.render(templatePath, context));
    }
    catch (FileException e)
    {
        writeln(format(templateError, htmlPath));
        exitDssg;
    }
}

private int serveProject(ushort port)
{
    writeln("Starting server...");
    writeln("Press Ctrl+C to quit.");

    auto settings = new HTTPServerSettings;
    settings.sessionStore = new MemorySessionStore;
    settings.port = port;
    settings.bindAddresses = ["::1", "127.0.0.1"];

    auto router = new URLRouter;
    router.get("*", serveStaticFiles(buildRoot));
    
    listenHTTP(settings, router);

    return runEventLoop();
}

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

private void getVersion()
{
    writeln(ver);
}