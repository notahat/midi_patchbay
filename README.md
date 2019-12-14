# MIDI Patchbay

MIDI patchbay lets you hook up your various pieces of MIDI software and hardware and pass MIDI data between them, applying assorted filters on the way. Things like key splits, MIDI channel remapping, transposition, etc. are made very simple.


## Requirements

* Mac OS X 10.15 or later
* External MIDI devices
* Other MIDI software such as a sequencer or soft synth


## Using MIDI Patchbay

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


## Credits

The software was designed and written by [Pete Yandell](https://notahat.com/)

Big thanks to Dan Wilcox ([ZKM | Hertz-lab](https://zkm.de/en/about-the-zkm/organisation/hertz-lab)) for his work on 64-bit support.

Thanks to Anthony Lauzon for many fixes.

Thanks to Kevan Staples for generously donating the MIDI Patchbay icon.

Many, many thanks to Kurt Revis both for writing [MIDI Monitor](http://www.snoize.com/MIDIMonitor), without which testing this thing would have been a nightmare, and for answering a million of my questions. Without his help I would have struggled over the code for a lot longer.


## Version History

### Version 1.1.0

* Rework of Catalina and 64-bit support, based on Dan Wilcox's 1.0.4 release
* Dark mode support

### Version 1.0.4 (November 2019, released by Dan Wilcox)

* Modernization for macOS 10.10+ (Dan Wilcox & Anthony Lauzon)
* Allow more then a single MIDI interface with the same name (Joshua Bates)
* Ported Read Me.html to README.md markdown (Martin Delille)

### Version 1.0.3 (5 June 2008)

* Fixed the build targets so that my release build script will correctly build a universal binary
* Updated the version strings to match SimpleSynth's style

### Version 1.0.2 (31 May 2008)

* Added an icon generously provided by Kevan Staples.

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
