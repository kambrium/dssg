// The functions required for creating and building a project

module dssg.core;

import dmarkdown;
import dssg.messages;
import dssg.sharedvalues;
import dssg.utilities;
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
        writeln(format(createErr, projectName));
    }
}

void buildProject()
{
    // Make sure that required directories exist
    if (templatesRoot.exists)
    {
        writeln(startingBuildMsg);

        handleBuildRoot;

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

        writeln(finishedBuildMsg);
    }
    else
    {
        writeln(dirStructureErr);
        exitDssg;
    }
}

private void handleBuildRoot()
{
    // Remove previous build or create new build directory
    try
    {
        if (buildRoot.exists)
        {
            foreach (DirEntry entry; dirEntries(buildRoot, SpanMode.shallow))
            {
                if (entry.isDir)
                {
                    rmdirRecurse(entry.name);
                }
                else if (entry.isFile)
                {
                    remove(entry.name);
                }
            }
            writeln(deletedBuildMsg);
        }
        else
        {
            mkdir(buildRoot);
        }
    }
    catch (FileException e)
    {
        writeln(deleteErr);
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
        writeln(format(inputFileErr, path));
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
        writeln(format(tomlParserErr, path));
        exitDssg;
    }

    // Prepare template context
    alias MustacheEngine!(string) Mustache;
    Mustache mustache;
    auto context = new Mustache.Context;

    string pageTemplate = "template";

    void walkTomlTree(TOMLValue[string] tvalue, ref Mustache.Context ctx)
    {
        foreach (string key, TOMLValue value; tvalue)
        {
            if (value.type == TOML_TYPE.TABLE)
            {
                auto subctx = ctx.addSubContext(key);
                walkTomlTree(value.table, subctx);
            }
            else if (value.type == TOML_TYPE.ARRAY) 
            {
                foreach (TOMLValue avalue; value.array)
                {
                    auto subctx = ctx.addSubContext(key);
                    walkTomlTree(avalue.table, subctx);
                }
            }
            else 
            {
                // Turn TOML value to string and drop quotation marks at the beginning and end of string
                string valueString = value.toString.drop(1).dropBack(1);
    
                // Unescaping valueString
                enum string[string] unescapingArray = [
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
    
                // Fill this level of the context.
                if (endsWith(key, "_md"))
                {
                    string contentHtml = filterMarkdown(valueString);
                    ctx[key] = contentHtml;
                } 
                else 
                {
                    ctx[key] = valueString;
                }
            }
        }
    }

    // Recurse through TOMLDocument
    walkTomlTree(tomlFromFile.table, context);
    try {
        pageTemplate = context["template"];
    }
    catch (core.exception.RangeError e) {
        pageTemplate = "template";
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
        writeln(format(templateErr, htmlPath));
        exitDssg;
    }
}
