module dssg.core;

import dssg.defaults;
import dssg.errormessages;
import dssg.utilities;
import dmarkdown;
import mustache;
import std.algorithm.searching;
import std.file;
import std.format;
import std.path;
import std.range;
import std.regex;
import std.stdio;
import std.utf;
import toml;

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

private void createBuildRoot()
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

private void processPage(string pageName, string path)
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