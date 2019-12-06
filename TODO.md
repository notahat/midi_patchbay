MIDI Patchbay To Do List
========================

Features
--------

* Additional filters:
  - controller messages
  - bank select/program change messages
  - pitch bend data
  - mod wheel data
  - sysex data
  - delay?
  - arpeggiator?
  - remapping of controller values
* Add the ability to cut, copy and paste patches
* Add the ability to reorder patches in a set
* Grouping of patches for fast/enabling disabling
* Keyboard/MIDI shortcuts for enabling/disabling patches
* More scalable user interface
* Plugin filter support
* Ability to have outputs show up in input list for looping through multiple filters

Improvements/Cleanups
---------------------

* Rewrite to use MIDIThruConnection interfaces for much better performance
* The input/output text should be reselected for editing after you are told that you've tried a duplicate name.  What does the UI do if we block things with an NSFormatter?
* Deleting an input/output that is in use should not be disallowed.  The user should be asked about it and given the option.  That would involve searching the patches and removing it from all patches that use it.

Done
----

* Rename TrafficTableCell...it's not a cell for the Traffic table! I should rename PatchTableCell while I'm at it.

_$Id: To\040Do.html,v 1.2.2.1 2004/01/12 12:18:01 pete Exp $_
