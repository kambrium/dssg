import core.exception;
import core.stdc.stdlib;
import dmarkdown;
import mustache;
import std.algorithm.searching;
import std.array;
import std.file;
import std.format;
import std.json;
import std.path;
import std.range.primitives;
import std.regex;
import std.stdio;
import std.utf;

// Constants 
enum ver = "0.1.0";

enum contentsRoot = "contents";
enum templatesRoot = buildPath(contentsRoot,"_templates");
enum buildRoot = "build";

enum invalidArgumentError = "ERROR: Invalid argument(s) given. HINT: Enter 'dssg help' for a list of valid arguments.";
enum invalidAmountError = "ERROR: Invalid amount of arguments given. HINT: Enter 'dssg help' for help.";
enum dirStructureError = format("ERROR: Could not find required directories '%s' and/or '%s'. HINT: Create them manually or use 'dssg new <name_of_new_project>'.", contentsRoot, templatesRoot);
enum createError = "ERROR: %s already exists. Try another name.";
enum deleteError = "ERROR: Could not delete build directory. HINT: Maybe a directory or file in the build directory is in use?";
enum inputFileError = "ERROR: Could not read file '%s'. HINT: Maybe it's not a text file.";
enum jsonError = "ERROR: Could not process JSON in file '%s'. HINT: Check JSON syntax and position of delimiter [SPLIT].";
enum templateError = "ERROR: Could not create HTML file '%s'. HINTS: Maybe the template's name specified in frontmatter is not correct. Maybe the default template (template.mustache) doesn't exist.";

void main(string[] args)
{ 
    // CLI handling
    try
    {
        switch (args[1])
        {
            case "new": assert(args.length == 3); createProject(args[2]); break;
            case "build": assert(args.length == 2); buildProject; break;
            case "help": assert(args.length == 2); showHelp; break;
            default: writeln(invalidArgumentError);
        }
    }
    catch (AssertError e)
    {
        writeln(invalidAmountError);
    }
    catch (RangeError e)
    {
        showHelp;
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
    try
    {
        assert(templatesRoot.exists);
    }
    catch (AssertError e)
    {
        writeln(dirStructureError);
        dssgExit;
    }
    
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
            // Process Markdown files
            else if (entry.isFile && endsWith(entry.name, ".md"))
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
        dssgExit;
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
        dssgExit;
    }

    // Split front matter and body at delimiter
    auto frontMatter = matchFirst(inputFromFile, regex(`(.*?)\[SPLIT\]`, "s"));
    auto contentMarkdown = matchFirst(inputFromFile, regex(`\[SPLIT\](.*)`, "s"));

    alias MustacheEngine!(string) Mustache;
    Mustache mustache;
    auto context = new Mustache.Context;

    // Deal with the front matter
    string pageTemplate = "template";
    JSONValue j;
    try
    {
        j = parseJSON(frontMatter[1]);
    }
    catch (JSONException e)
    {
        writeln(format(jsonError, path));
        dssgExit;
    }
    foreach (string key, value; j)
        if (key == "template")
        {
            pageTemplate = value.str;
        }
        else
        {
            context[key] = value.str;
        }

    // Deal with the body
    string contentHtml = filterMarkdown(contentMarkdown[1]);
    context["CONTENT"] = contentHtml;

    // Deal with relative URLs in templates
    auto pathItems = pathSplitter(path).array;
    ulong pathItemsAmount = pathItems.length;
    context["ROOT"] = "../".replicate(pathItemsAmount-1);
    
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
        dssgExit;
    }
}

void showHelp()
{
    // Help text
    writeln(format("DSSG - A static site generator written in D - Version %s", ver));
    writeln("");
    writeln("Usage:");
    writeln("  dssg new <project_name>  Create a new DSSG project");
    writeln("  dssg build               Build a DSSG project");
    writeln("  dssg help                Read this help text");
}

void dssgExit()
{
    writeln("Build not finished. Exiting...");
    exit(0);
}