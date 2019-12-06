#import <AppKit/AppKit.h>
#import <PYMIDI/PYMIDI.h>

@class WindowWithUndo;

@class Patch;
@class PatchSet;
@class VirtualEndpointSet;

@class PatchTableDataSource;
@class EndpointTableDataSource;


@interface PatchbayDocument : NSDocument <NSWindowDelegate> {
    IBOutlet NSWindow*			documentWindow;
    
    // Stuff related to the table of patches
    
    IBOutlet NSTableView*		patchTable;
    PatchTableDataSource*		patchTableDataSource;
    
    NSMutableArray*				patchArray;
    Patch*						selectedPatch;
    int                         selectedIndex;
    
    // Stuff related to editing a patch
    
    IBOutlet NSPopUpButton*		inputPopUp;

    IBOutlet NSMatrix*			filterChannelRadioButtons;
    IBOutlet NSMatrix*			filterChannelMatrix;
    
    IBOutlet NSMatrix*			filterRangeRadioButtons;
    IBOutlet NSSlider*			lowestAllowedNoteSlider;
    IBOutlet NSTextField*		lowestAllowedNoteField;
    IBOutlet NSStepper*			lowestAllowedNoteStepper;
    IBOutlet NSTextField*		filterRangeLabelField;
    IBOutlet NSSlider*			highestAllowedNoteSlider;
    IBOutlet NSTextField*		highestAllowedNoteField;
    IBOutlet NSStepper*			highestAllowedNoteStepper;
    
    IBOutlet NSButton*			transposeButton;
    IBOutlet NSSlider*			transposeDistanceSlider;
    IBOutlet NSTextField*		transposeDistanceField;
    IBOutlet NSStepper*			transposeDistanceStepper;
    
    IBOutlet NSButton*			remapChannelButton;
    IBOutlet NSPopUpButton*		remapChannelPopUp;
    
    IBOutlet NSButton*			transmitClockButton;

    IBOutlet NSPopUpButton*		outputPopUp;
    
    
    // Stuff related to virtual endpoints
    
    IBOutlet NSPanel*			virtualEndpointPanel;
    BOOL						panelWasOpenedToInputs;
    IBOutlet NSTabView*			virtualEndpointTabView;
    
    IBOutlet NSTableView*		inputTable;
    EndpointTableDataSource*	inputTableDataSource;
    
    IBOutlet NSTableView*		outputTable;
    EndpointTableDataSource*	outputTableDataSource;
    
    NSMutableArray*				virtualSourceArray;
    NSMutableArray*				virtualDestinationArray;
}

- (id)init;
- (void)windowControllerDidLoadNib:(NSWindowController*)windowController;
- (void)dealloc;

- (NSData*)dataRepresentationOfType:(NSString*)type;
- (BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;
- (void)syncWithLoadedData;

- (NSString*)windowNibName;

- (NSUndoManager*)windowWillReturnUndoManager:(NSWindow*)sender;

- (void)midiSetupChanged:(NSNotification*)notification;

#pragma mark Patch table

- (void)selectedPatchChanged:(NSNotification*)notification;
- (IBAction)addRemovePatchButtonPressed:(NSSegmentedControl*)sender;
- (void)addPatchButtonPressed:(id)sender;
- (void)removePatchButtonPressed:(id)sender;

- (void)addPatch:(Patch*)patch atIndex:(int)index;
- (void)addPatchFromArchive:(NSData*)data atIndex:(int)index;
- (void)removePatchAtIndex:(int)index;
- (void)setIsEnabled:(BOOL)isEnabled forPatch:(Patch*)patch;

- (NSData*)archivePatchForPasteBoard:(Patch*)patch;
- (Patch*)unarchivePatchFromPasteBoard:(NSData*)data;

#pragma mark Patch editing - MIDI Input

- (void)buildInputPopUp;
- (void)setInputPopUp;
- (IBAction)inputPopUpChanged:(id)sender;
- (void)setInput:(PYMIDIEndpoint*)input forPatch:(Patch*)patch;

#pragma mark Patch editing - Channel filter

- (void)buildFilterChannelControls;
- (void)setFilterChannelControls;
- (IBAction)filterChannelRadioButtonsChanged:(id)sender;
- (void)setShouldFilterChannel:(BOOL)shouldFilterChannel forPatch:(Patch*)patch;
- (IBAction)filterChannelMatrixChanged:(id)sender;
- (void)setChannelMask:(unsigned int)channelMask forPatch:(Patch*)patch;

#pragma mark Patch editing - Channel remapping

- (void)buildRemapChannelControls;
- (void)setRemapChannelControls;
- (IBAction)remapChannelButtonChanged:(id)sender;
- (void)setShouldRemapChannel:(BOOL)shouldRemapChannel forPatch:(Patch*)patch;
- (IBAction)remapChannelPopUpChanged:(id)sender;
- (void)setRemappingChannel:(int)channel forPatch:(Patch*)patch;

#pragma mark Patch editing - Range filtering

- (void)buildFilterRangeControls;
- (void)setFilterRangeControls;
- (IBAction)filterRangeRadioButtonsChanged:(id)sender;
- (void)setShouldAllowNotes:(BOOL)shouldAllowNotes forPatch:(Patch*)patch;
- (void)setShouldFilterRange:(BOOL)shouldFilterRange forPatch:(Patch*)patch;
- (IBAction)lowestAllowedNoteSliderChanged:(id)sender;
- (IBAction)lowestAllowedNoteStepperChanged:(id)sender;
- (void)setLowestAllowedNote:(Byte)note forPatch:(Patch*)patch;
- (IBAction)highestAllowedNoteSliderChanged:(id)sender;
- (IBAction)highestAllowedNoteStepperChanged:(id)sender;
- (void)setHighestAllowedNote:(Byte)note forPatch:(Patch*)patch;

#pragma mark Patch editing - Transposition

- (void)buildTransposeControls;
- (void)setTransposeControls;
- (IBAction)transposeButtonChanged:(id)sender;
- (void)setShouldTranspose:(BOOL)shouldTranspose forPatch:(Patch*)patch;
- (IBAction)transposeDistanceSliderChanged:(id)sender;
- (IBAction)transposeDistanceStepperChanged:(id)sender;
- (void)setTransposeDistance:(int)distance forPatch:(Patch*)patch;

#pragma mark Patch editing - Clock

- (void)buildTransmitClockControls;
- (void)setTransmitClockControls;
- (IBAction)transmitClockButtonChanged:(id)sender;
- (void)setShouldTransmitClock:(BOOL)state forPatch:(Patch*)patch;

#pragma mark Patch editing - MIDI Output

- (void)buildOutputPopUp;
- (void)setOutputPopUp;
- (IBAction)outputPopUpChanged:(id)sender;
- (void)setOutput:(PYMIDIEndpoint*)output forPatch:(Patch*)patch;

#pragma mark Virtual endpoints

- (IBAction)addRemoveInputButtonPressed:(NSSegmentedControl*)sender;
- (void)addInputButtonPressed:(id)sender;
- (void)removeInputButtonPressed:(id)sender;

- (IBAction)addRemoveOutputButtonPressed:(NSSegmentedControl*)sender;
- (void)addOutputButtonPressed:(id)sender;
- (void)removeOutputButtonPressed:(id)sender;

- (IBAction)endpointPanelButtonPressed:(id)sender;

- (void)endpointPanelDidEnd:(NSWindow*)sheet returnCode:(NSModalResponse)returnCode contextInfo:(void*)contextInfo;

@end
