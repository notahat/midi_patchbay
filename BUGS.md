MIDI Patchbay Bugs
==================

Open
----

* MIDI inputs and outputs are sorted alphabetically rather than by port number.

* Sometimes virtual endpoints can't be deleted even when no patch is obviously using them because an old patch can be sitting on the undo stack. The way to fix this is that patches that are in limbo should unregister themselves with the endpoints with which they are talking.

* Creating a document, creating a virtual input or output then hitting undo will not reset the document saved flag for some reason. It has something to do with the undo grouping used by the virtual endpoint sheet, because if I disable that the problem goes away.

* Creating a MIDI routing loop will crash the OS! It's really easy to do on Panther with IAC busses.

* Select All in the Edit menu is enabled when editing the patch list despite the fact that only one patch can be selected at a time

* Running an old version of MIDI Patchbay will show Open Recent menu items from the new version even if the old version doesn't support files

* Start a new document, create a new virtual input, hit undo...the document is still marked as changed and requiring saving.  (Maybe this has to do with the use of undo groups?)

* Choosing the "Edit Virtual Inputs/Outputs..." options from the input or output popup menus will briefly cause this to become the selected item, and will only flick back to the real selected item after a second or so. It's very annoying visually.

* Moving the lowest allowed note or highest allowed note sliders will cause a lot of undo events to be registered, which is a bit of a waste of memory.

Closed
------

* There *may* be problems when multiple inputs are patched through to a single real output.  If you see issues in this situation, please report them.  This should not happen under OS X 10.1.5 or later.
