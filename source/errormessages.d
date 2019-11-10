module errormessages;

import defaults;
import std.format;

enum invalidArgumentError = "ERROR: Invalid argument(s) given. HINT: Enter 'dssg help' for a list of valid arguments.";
enum invalidAmountError = "ERROR: Invalid amount of arguments given. HINT: Enter 'dssg help' for help.";
enum dirStructureError = format("ERROR: Could not find required directories '%s' and/or '%s'. HINT: Create them manually or use 'dssg new <name_of_new_project>'.", contentsRoot, templatesRoot);
enum invalidTypeError = "ERROR: %s is not a valid port number.";
enum createError = "ERROR: %s already exists. Try another name.";
enum deleteError = "ERROR: Could not delete build directory. HINT: Maybe a directory or file in the build directory is in use?";
enum inputFileError = "ERROR: Could not read file '%s'. HINT: Maybe it's not a text file.";
enum templateError = "ERROR: Could not create HTML file '%s'. HINTS: Maybe the template's name specified in frontmatter is not correct. Maybe the default template (template.mustache) doesn't exist.";
enum tomlParserError = "ERROR: Could not parse TOML file '%s'. HINT: Check your TOML syntax.";