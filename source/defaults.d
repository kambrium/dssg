module defaults;

import std.path;

// Default directories
enum contentsRoot = "contents";
enum templatesRoot = buildPath(contentsRoot,"_templates");
enum buildRoot = "build";

// Default port
ushort port = 4242;