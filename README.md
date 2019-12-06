MIDI Patchbay (Version 1.0.4)
=============================

MIDI patchbay lets you hook up your various pieces of MIDI software and hardware and pass MIDI data between them, applying assorted filters on the way. Things like key splits, MIDI channel remapping, transposition, etc. are made very simple.

* [License](#license)
* [Requirements](#requirements)
* [Using MIDI Patchbay](#usage)
* [Known Problems](#problems)
* [Future Additions](#future)
* [Credits](#credits)
* [Version History](#history)

<a name="license"></a>License
-----------------------------

This software is distributed under the terms of [Pete's Public License](License.html).  It's free (as in beer) but the license sets out a few restrictions on its distribution and modification.

If you use it I only ask for one thing: [send me an e-mail](#mailto:pete@notahat.com).  Tell me what you use it for, anything you like and don't like, anything you'd like to see in future versions, etc.

For other ways to reward me for producing this, see[my web site](#http://www.notahat.com/software/).

<a name="requirements"></a>Requirements
---------------------------------------

* Mac OS X 10.2 or later
* A MIDI interface with OS X drivers
* Other MIDI software such as a sequencer or soft synth

If you're looking for MIDI interface drivers or audio and MIDI applications for Mac OS X, check out my [links page](#http://pete.yandell.com/links/).

<a name="usage"></a>Using MIDI Patchbay
---------------------------------------

Each MIDI Patchbay document window is divided into two parts: a patch list on the left and a set of patch controls on the right.

### The Patch List

Each patch in the list represents a connection between a MIDI input and MIDI output.  The patch's input is shown on the left of the arrow and the patch's output on the right.

Below each patch's arrow is a description of the data passed by the patch and any filters that are applied to the data.

Each patch also has a checkbox that can be used to enable or disable it.

New patches can be created with the *Add patch* button. MIDI Patchbay tries to create new patches intelligently based on the currently selected patch.

### The Patch Controls

The patch controls configure the input, output and filters for the currently selected patch.

The MIDI input and output for the patch can be selected from the appropriate popup menus.  As well as the MIDI interfaces connected to your system, you can use the *Edit virtual inputs/outputs...* options to create inputs and outputs that will be visible to other MIDI software.

Under the various tabs are options allowing you to filter the MIDI data for the currently selected patch.

### Example: Creating a Keyboard Split

* Create a new MIDI Patchbay document
* Select the first patch in the list on the left
* From the *MIDI Input* popup menu choose your MIDI interface
* From the *MIDI Output* popup menu, select *Edit virtual outputs...*
* Create a new output named *Example output* and click *OK*
* Select *Example output* in the *MIDI Output* popup menu
* In the *Channels* tab, check the *Remap all data to MIDI channel:* button and choose channel 1
* In the *Notes* tab, check the *Only allow notes in the range:* button and slide the lower slider until the note A4 is selected
* Click the *Add Patch* button.  Note that the new patch created is intelligently based on the currently selected patch and already has the other half of the keyboard selected as its range of filtered notes and has its traffic remapped to channel 2.
* Open your favourite synth software and select *Example Output* as its MIDI input

Now any notes up to A4 will be sent your synth software's MIDI channel 1 and notes above A4 will go to channel 2.

<a name="problems"></a>Known Problems
-------------------------------------

### Creating a MIDI routing loop can crash OS X

For example, creating a patch that receives from and sends to the one IAC bus is a bad idea. As soon as MIDI data gets sent to that IAC bus the entire computer will lock up.

You also have to be careful not to create indirect loops, as can easily happen with Logic.

### Using MIDI Patchbay with Logic

Using MIDI Patchbay with Logic can crash the computer, but the problem is easily worked around.

If you open a default song in Logic it will open with a MIDI track enabled as MIDI thru. The default MIDI instrument is set to *all* for the OUT port.

If your MIDI Patchbay document contains a patch that routes from a virtual input to a virtual output, this creates a MIDI routing loop. Logic sends instrument settings into this loop at song-open and, hence, a crash occurs.

You can work around it by first disabling the patches in MIDI Patchbay, opening Logic and turning off MIDI Thru, and then re-enabling the patches in MIDI Patchbay.

### MIDI and Classic

Some people have reported problems when trying to use Classic and a MIDI interface simultaneously.  It seems that Classic will try to grab control of USB devices.  When using this software, you should make sure that Classic is not running.

### Deleting virtual inputs and outputs

Sometimes trying to delete a virtual input or output will give you a message saying that the input or output is in use by a patch and can't be deleted even when it isn't. Saving, closing and re-opening the document will fix this.

<a name="future"></a>Future Additions
-------------------------------------

This is what's currently on my to do list for MIDI Patchbay in rough order
of priority:

* Additional filters:
 * remapping of controller messages
 * bank select/program change messages
 * pitch bend data
 * mod wheel data
 * sysex data
 * delay MIDI data (build your own arpeggiator!)
 * transpose within a key (magic harmonies!)
* Copy and paste of patches
* Grouping of patches and assigning of keyboard/MIDI event shortcuts to enable or disable groups for live use
* Spiffier interface which takes up less screen space and has neat ways of doing things like keyboard splits or arpeggiation

<a name="credits"></a>Credits
----------------------------------

The software was designed and written by [Pete Yandell](mailto:pete@notahat.com)

Thanks to Kevan Staples for generously donating the MIDI Patchbay icon.

Many, many thanks to Kurt Revis both for writing [MIDI Monitor](http://www.snoize.com/MIDIMonitor), without which testing this thing would have been a nightmare, and for answering a million of my questions. Without his help I would have struggled over the code for a lot longer.

<a name="history"></a>Version History
-------------------------------------

### Version 1.0.4 (??? 2019)

* Modernization for macOS 10.10+ (Dan Wilcox & Anthony Lauzon)
* Allow more then a single MIDI interface with the same name (Joshua Bates)
* Ported Read Me.html to README.md markdown (Martin Delille) as well as BUGS.md and TODO.md

### Version 1.0.3 (5 June 2008)

* Fixed the build targets so that my release build script will correctly build a universal binary
* Updated the version strings to match SimpleSynth's style

### Version 1.0.2 (31 May 2008)

* Added an icon generously provided by Kevan Staples

### Version 1.0.1 (13 January 2004)

* Fixed bugs to do with handling of MIDI devices on OS X 10.3
* Fixed a major bug with undo handling that caused deleted patches to invisibly hang around and keep working in certain circumstances
* The default patch in an empty document will no longer use IAC bus endpoints in order to avoid creating potential MIDI routing loops
* Text in the patch list gets an ellipsis on the end when truncated

### Version 1.0 (1 February 2003)

* Patch sets can be saved and loaded
* Undo works
* External device names as configured in Audio MIDI Setup are used when available
* The interface now uses tabs, is a lot more compact and allows windows to be resized
* Middle C is now displayed as C4 (rather than C5)

### Version 0.2 (29 June 2002)

* Virtual MIDI inputs and outputs can now be edited
* OS X 10.1.5 is now required, as this fixes a couple of MIDI bugs which were causing grief, particularly with realtime data

* A switch to allow MIDI clock/realtime data through patches has been added
* The MIDI channel filtering controls now work
* The window now remembers its position between application restarts
* Up and down arrow keys work in the list of patches
* Patches can now be deleted
* Creating a new patch from a patch with a range filter set and an upper note of G10 no longer causes errors

### Version 0.1 (21 February 2002)

* initial release

***

*Copyright &copy; 2003-2019 [Peter Yandell](mailto:pete@notahat.com).* All Rights Reserved.
