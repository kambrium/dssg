// Values shared between other modules

module dssg.sharedvalues;

import std.path;

// Directories
enum contentsRoot = "contents";
enum templatesRoot = buildPath(contentsRoot,"_templates");
enum buildRoot = "build";

// Default port
ushort port = 4242;