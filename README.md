# general_utilities

# (this repo basically 100% deprecated)
Note: This is all old stuff. Most of the scripts have a dealbreaker in them, so to speak.
There's an excessive use of class_name's. Many scripts are redundant with modern Godot features
(such as interp scripts). Classes like ByteUtils literally have certain functions that are bugs.
ByteUtils in particular is pretty bad, since function calls in GDScript aren't exactly free. The
abstraction really isn't worth it. Also, stuff like the console is missing a lot of basic features
that I've added over time in other projects, and I just haven't updated the repo to reflect it. Part
of this is because in a more recent project, I've completely overhauled my file naming style from
`Capitalized Names For Files` to `snake_case`, which would break the history of the repo, and I don't
want to deal with copy-pasting file contents all the time instead of my old lazy way of just copy-pasting
the most recent files. Anyway, long story short, this repo doesn't reflect the utils that I use in my current
Godot projects.

# Here's the old stuff.
General utility scripts, 'namespaces' and singletons that I use in most of my Godot projects.

There are 3 types of scripts in this repo. There are singletons, which are intended to be added to a
project's autoload. The order I use is Quack --> Inputs --> Console. There are 'namespaces', which are intended to
never be directly instantiated when the project is running. They are rather used as namespaces in
projects. Hence, why they do not contain any variables or non-static functions. NOTE: When I refer to
"macros", I mean static functions that are intended to either abstract or shorthand functions that
would otherwise be accessible in the same context. These "macros" avoid confusion and verbosity.
For example, to figure out if the root viewport is running in windowed mode, someone could either
create the statement "get_tree().get_root().get_mode() == Window.MODE_WINDOWED", or they could call
"WindowUtils.is_root_windowed()".

SINGLETONS:
Quack: A singleton that previously contained the functionality that's now been moved to other .gd scripts.
Now, it primarily serves as a collection of miscellaneous functions. Includes shorthand variable accessors
for the game's SceneTree and root viewport, and functions to help disconnect signals from objects without
knowing which signals are currently connected.

Inputs: A singleton that provides macros and signals related to processing inputs. This script updates
every time the engine processes a local input, and if that input event is a mouse being moved, the script
emits the signal "mouse_moved", along with the mouse's motion. If the input event is the "ui_cancel" action
being inputted, the signal "pause_pressed" is emitted.

PREFABS:
Fill List: VBoxContainer that aligns all children of any of its child HBoxContainers to be equidistant from
the horizontal distances specified. Similar to the "Justify" text alignment in traditional text editors.

Int Range: TBH, I'm not entirely sure why this is called "Int Range". The purpose of this is to create a
SpinBox with an exposed Font override, and an exposed font size override.

Menu: Prefab for switching 'layers' of menus, which allows designers to easily work on modifying the UI of
a menu, without needing to worry about switching certain menus to be hidden, and the startup menu to be
shown again. Also makes switching between menus much easier with a 'layer' switching system.

Toggle Button: Normal button (should be set to toggle in its parameters) that changes its text depending
on if it is toggled or not.

Interp 3D Component: RefCounted intended to be instantiated as a member variable of another script. Makes
it much easier for 3D objects to interpolate and still make fixed physics movements in script. The
component does not process on frames and physics frames on its own, and its 'parent' script must call
these on its own.

NAMESPACES:
Collision: 

Byte Utilities: Called as ByteUtils, this namespace contains functions that operate on the bits of ints and
PackedByteArrays. This helps to make bit operations more abstract and accessible to people editing code,
thereby making a project's code more understandable. i.e. It's much easier for a newbie to understand
"set the third bit in this number to true" rather than "number |= 1<<3" or "number |= 4". Also includes
some functions to make sure that numbers are within u8 and u16 ranges.

Label Utilities: A bunch of macros that make it easier to set individual label theme override properties
through script.

Resources: Static funcs and consts that help Quack load resources. TBH, it might make more 'sense' to access
resources from this script, instead of Quack. I could totally make a constant Array of Resources using load()s.
But Quack.get_resource(Resources.SOMETHING) is slightly shorter than Resources.get_resource(Resources.SOMETHING),
or Resources.spawn(Resources.SOMETHING)... so I'm leaving it the way it currently is.

Window Utilities: A bunch of macros that make it easier to perform actions on windows through script.
These actions include renaming window titles, checking if windows are in fullscreen mode, setting the
size of windows, etc. Also includes constants to access various video settings.

Console: Need to work on making it more user-friendly and not yoinked from someone else
