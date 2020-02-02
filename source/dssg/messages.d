// The messages used in the application

module dssg.messages;

import dssg.sharedvalues;
import std.format;

enum invalidArgumentErr = "ERROR: Invalid argument(s) given. HINT: Enter 'dssg help' for a list of valid arguments.";
enum invalidAmountErr = "ERROR: Invalid amount of arguments given. HINT: Enter 'dssg help' for help.";
enum dirStructureErr = format("ERROR: Could not find required directories '%s' and/or '%s'. HINT: Create them manually or use 'dssg new <name_of_new_project>'.", contentsRoot, templatesRoot);
enum invalidTypeErr = "ERROR: %s is not a valid port number.";
enum createErr = "ERROR: %s already exists. Try another name.";
enum deleteErr = "ERROR: Could not delete build directory. HINT: Maybe a directory or file in the build directory is in use?";
enum inputFileErr = "ERROR: Could not read file '%s'. HINT: Maybe it's not a text file.";
enum templateErr = "ERROR: Could not create HTML file '%s'. HINTS: Maybe the template's name specified in frontmatter is not correct. Maybe the default template (template.mustache) doesn't exist.";
enum tomlParserErr = "ERROR: Could not parse TOML file '%s'. HINT: Check your TOML syntax.";

enum startingBuildMsg = "Starting the build process...";
enum finishedBuildMsg = "Finished new build.";
enum deletedBuildMsg = "Deleted previous build.";
enum startingServerMsg = "Starting server... Press Ctrl+C to quit.";
enum exitingMsg = "Build not finished. Exiting...";

enum string[] helpMsg = [
    "DSSG - A static site generator written in D",
    "",
    "Usage:",
    "  dssg new <project_name>  Create a new DSSG project",
    "  dssg build               Build a DSSG project",
    "  dssg serve [<port>]      Serve DSSG project. Standard port is 4242",
    "  dssg version             Get DSSG version",
    "  dssg help                Read this help text"
];