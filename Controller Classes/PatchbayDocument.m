#import "PatchbayDocument.h"
#import "PYMIDI/PYMIDI.h"
#import "Patch.h"
#import "PatchTableCell.h"
#import "PatchTableDataSource.h"
#import "EndpointTableDataSource.h"


@implementation PatchbayDocument


- (id)init
{
    self = [super init];
    
    if (self == nil) return nil;
    
    // Pick a default input and output for a blank patch
    PYMIDIManager*	manager = [PYMIDIManager sharedInstance];
    
    NSArray* sources = [manager realSources];
    NSEnumerator* enumerator = [sources objectEnumerator];
    PYMIDIEndpoint* input;
    do { input = [enumerator nextObject]; } while ([input isIACBus]);

    NSArray* destinations = [manager realDestinations];
    enumerator = [destinations objectEnumerator];
    PYMIDIEndpoint* output;
    do { output = [enumerator nextObject]; } while ([output isIACBus]);
    
    // Patch related initialisation
    selectedPatch = [[Patch alloc] initWithInput:input output:output];
    [selectedPatch rescueFromLimbo];
    patchArray = [[NSMutableArray alloc] initWithObjects:selectedPatch, nil];
    [selectedPatch release];

    // Virtual endpoint related initialisation
    virtualSourceArray      = [[NSMutableArray alloc] init];
    virtualDestinationArray = [[NSMutableArray alloc] init];
    
    // Uncomment the following line for debugging if you want to
    // disable undo, which makes tracking retain/release issues easier.
    //[self setUndoManager:nil];

    return self;
}


- (void)windowControllerDidLoadNib:(NSWindowController*)windowController
{
    NSButtonCell*		buttonCell;
    PatchTableCell*		patchTableCell;
    
    [super windowControllerDidLoadNib:windowController];

    // These are so that our window and panel use the correct undo manager
    
    [documentWindow setDelegate:self];
    [virtualEndpointPanel setDelegate:self];
    
    
    // Set up the patch related stuff
    
    buttonCell = [[NSButtonCell alloc] init];
    [buttonCell setButtonType:NSSwitchButton];
    [buttonCell setTitle:@""];
    [[patchTable tableColumnWithIdentifier:@"enabled"] setDataCell:buttonCell];
    [buttonCell release];
    
    patchTableCell = [[PatchTableCell alloc] init];
    [[patchTable tableColumnWithIdentifier:@"patch"] setDataCell:patchTableCell];
    [patchTableCell release];
    
    patchTableDataSource = [[PatchTableDataSource alloc] initWithDocument:self patchArray:patchArray];
    [patchTable setDataSource:patchTableDataSource];
    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(selectedPatchChanged:)
        name:@"NSTableViewSelectionDidChangeNotification" object:patchTable
    ];
    
    [self buildInputPopUp];
    [self buildFilterChannelControls];
    [self buildRemapChannelControls];
    [self buildFilterRangeControls];
    [self buildTransposeControls];
    [self buildTransmitClockControls];
    [self buildOutputPopUp];

    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(midiSetupChanged:)
        name:@"PYMIDISetupChanged" object:nil
    ];


    // Set up the virtual endpoint related stuff
    
    inputTableDataSource = [[EndpointTableDataSource alloc]
        initWithEndpointClass:[PYMIDIVirtualDestination class]
        endpointArray:virtualDestinationArray
        undoManager:[self undoManager]
    ];
    [inputTable setDataSource:inputTableDataSource];
    [inputTable setDelegate:inputTableDataSource];
    
    outputTableDataSource = [[EndpointTableDataSource alloc]
        initWithEndpointClass:[PYMIDIVirtualSource class]
        endpointArray:virtualSourceArray
        undoManager:[self undoManager]
    ];
    [outputTable setDataSource:outputTableDataSource];
    [outputTable setDelegate:outputTableDataSource];
    
    // See the comment on tabView:shouldSelectTabViewItem; in EndpointTableDataSource
    [virtualEndpointTabView setDelegate:inputTableDataSource];
    
    
    [self syncWithLoadedData];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [patchTableDataSource release];
    [patchArray release];
    
    [inputTableDataSource release];
    [outputTableDataSource release];
    
    [virtualSourceArray release];
    [virtualDestinationArray release];
    
    [super dealloc];
}



- (NSData*)dataRepresentationOfType:(NSString*)type
{
    NSMutableData*		data;
    NSKeyedArchiver*	archiver;
    
    data = [NSMutableData data];
    archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
    
    [archiver encodeObject:virtualSourceArray      forKey:@"virtualSourceArray"];
    [archiver encodeObject:virtualDestinationArray forKey:@"virtualDestinationArray"];
    [archiver encodeObject:patchArray              forKey:@"patchArray"];
    
    [archiver finishEncoding];
    [archiver release];
    
    return data;
}


- (BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type
{
    [patchArray release];
    [virtualDestinationArray release];
    [virtualSourceArray release];

    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    virtualDestinationArray = [[unarchiver decodeObjectForKey:@"virtualDestinationArray"] retain];
    
    virtualSourceArray = [[unarchiver decodeObjectForKey:@"virtualSourceArray"] retain];
    
    patchArray = [[unarchiver decodeObjectForKey:@"patchArray"] retain];
    [patchArray makeObjectsPerformSelector:@selector(rescueFromLimbo)];
    
    [unarchiver finishDecoding];
    [unarchiver release];
    
    // We need to do this to handle redisplay of the new data when a Revert is done
    [self syncWithLoadedData];
    
    return YES;
}


- (void)syncWithLoadedData
{
    // If we haven't gone through windowControllerDidLoadNib: yet then we don't
    // have an interface to update, so just return.
    if (patchTableDataSource == nil) return;
    
    
    [patchTableDataSource setPatchArray:patchArray];
    [patchTable reloadData];

    if ([patchArray count] > 0)
        [patchTable selectRow:0 byExtendingSelection:NO];
    else
        [patchTable deselectAll:self];
    
    [self selectedPatchChanged:nil];
    
    
    [inputTableDataSource setEndpointArray:virtualDestinationArray];
    [inputTable reloadData];
    
    [outputTableDataSource setEndpointArray:virtualSourceArray];
    [outputTable reloadData];
}



- (NSString*)windowNibName
{
    return @"PatchbayDocument";
}



- (NSUndoManager*)windowWillReturnUndoManager:(NSWindow*)sender
{
    return [self undoManager];
}



- (void)midiSetupChanged:(NSNotification*)notification
{
    [self buildInputPopUp];
    [self setInputPopUp];
    [self buildOutputPopUp];
    [self setOutputPopUp];
    [patchTable reloadData];
}



#pragma mark Patch table


- (void)selectedPatchChanged:(NSNotification*)notification
{
    NSInteger patchIndex = [patchTable selectedRow];
    
    if (patchIndex != -1)
        selectedPatch = [patchArray objectAtIndex:patchIndex];
    else
        selectedPatch = nil;
     
    [self setInputPopUp];
    [self setFilterChannelControls];
    [self setRemapChannelControls];
    [self setFilterRangeControls];
    [self setTransposeControls];
    [self setTransmitClockControls];
    [self setOutputPopUp];
}


- (IBAction)addPatchButtonPressed:(id)sender
{
    Patch* patch;
    
    if (selectedPatch != nil) {
        patch = [[Patch alloc] initFromPatch:selectedPatch];
    }
    else {
        // Pick a default input and output for a blank patch
        PYMIDIManager*	manager = [PYMIDIManager sharedInstance];
        
        NSArray* sources = [manager realSources];
        NSEnumerator* enumerator = [sources objectEnumerator];
        PYMIDIEndpoint* input;
        do { input = [enumerator nextObject]; } while ([input isIACBus]);

        NSArray* destinations = [manager realDestinations];
        enumerator = [destinations objectEnumerator];
        PYMIDIEndpoint* output;
        do { output = [enumerator nextObject]; } while ([output isIACBus]);

        patch = [[Patch alloc] initWithInput:input output:output];
    }
    
    [self addPatch:patch atIndex:[patchArray count]];
    
    [patch release];
}


- (void)addPatch:(Patch*)patch atIndex:(NSUInteger)index
{
    NSUndoManager* undoManager = [self undoManager];    

    [patch rescueFromLimbo];
    [patchArray insertObject:patch atIndex:index];
    
    [patchTable reloadData];
    [patchTable selectRow:index byExtendingSelection:NO];

    [[undoManager prepareWithInvocationTarget:self]
        removePatchAtIndex:index
    ];
}


- (void)addPatchFromArchive:(NSData*)data atIndex:(NSUInteger)index
{
    Patch* patch = [self unarchivePatchFromPasteBoard:data];
    
    [patch rescueFromLimbo];
    [self addPatch:patch atIndex:index];
}


- (void)removePatchAtIndex:(NSUInteger)index
{
    NSUndoManager* undoManager = [self undoManager];
    Patch* patch = [[patchArray objectAtIndex:index] retain];
    
    [patch banishToLimbo];
    [patchArray removeObjectAtIndex:index];

    [patchTable reloadData];

    [[undoManager prepareWithInvocationTarget:self]
        addPatch:patch atIndex:index
    ];
    
    [patch release];
}


- (void)setIsEnabled:(BOOL)isEnabled forPatch:(Patch*)patch
{
    NSUndoManager* undoManager = [self undoManager];    
    BOOL wasEnabled;
    
    wasEnabled = [patch isEnabled];
    
    [patch setIsEnabled:isEnabled];
    [patchTable reloadData];
    
    [[undoManager prepareWithInvocationTarget:self]
        setIsEnabled:wasEnabled forPatch:patch
    ];
}


- (NSData*)archivePatchForPasteBoard:(Patch*)patch
{
    NSArray*				endpointArray;
    PYMIDIEndpointSet*		endpointSet;
    NSMutableData*			data;
    NSKeyedArchiver*		archiver;
    
    endpointArray = [virtualSourceArray arrayByAddingObjectsFromArray:virtualDestinationArray];
    endpointSet = [PYMIDIEndpointSet endpointSetWithArray:endpointArray];
    
    data = [NSMutableData data];
    archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archiver setDelegate:endpointSet];
    
    [archiver encodeObject:patch forKey:@"patch"];
    
    [archiver finishEncoding];
    [archiver release];

    return data;
}


- (Patch*)unarchivePatchFromPasteBoard:(NSData*)data
{
    NSArray*				endpointArray;
    PYMIDIEndpointSet*		endpointSet;
    NSKeyedUnarchiver*		unarchiver;
    Patch*					patch;

    endpointArray = [virtualSourceArray arrayByAddingObjectsFromArray:virtualDestinationArray];
    endpointSet = [PYMIDIEndpointSet endpointSetWithArray:endpointArray];

    unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [unarchiver setDelegate:endpointSet];
    
    patch = [unarchiver decodeObjectForKey:@"patch"];
    
    [unarchiver finishDecoding];
    [unarchiver release];
    
    return patch;
}



#pragma mark Patch editing - MIDI Input


- (void)buildInputPopUp
{
    PYMIDIManager*	manager = [PYMIDIManager sharedInstance];
    NSArray*		realSources;
    NSEnumerator*	enumerator;
    PYMIDIEndpoint*	input;

    [inputPopUp removeAllItems];

    realSources = [manager realSources];
    
    enumerator = [realSources objectEnumerator];
    while (input = [enumerator nextObject]) {
        [inputPopUp addItemWithTitle:[input displayName]];
        [[inputPopUp lastItem] setRepresentedObject:input];
    }

    if ([realSources count] > 0 && [virtualDestinationArray count] > 0)
        [[inputPopUp menu] addItem:[NSMenuItem separatorItem]];
   
	enumerator = [virtualDestinationArray objectEnumerator];
    while (input = [enumerator nextObject]) {
        [inputPopUp addItemWithTitle:[input displayName]];
        [[inputPopUp lastItem] setRepresentedObject:input];
    }
    
    if ([realSources count] > 0 || [virtualDestinationArray count] > 0)
        [[inputPopUp menu] addItem:[NSMenuItem separatorItem]];
        
    [inputPopUp addItemWithTitle:@"Edit Virtual Inputs..."];
    [[inputPopUp lastItem] setTarget:self];
    [[inputPopUp lastItem] setAction:@selector(editVirtualInputs:)];
}


- (void)setInputPopUp
{
    if (selectedPatch != nil) {
        [inputPopUp setEnabled:YES];
        [inputPopUp selectItemAtIndex:[inputPopUp indexOfItemWithRepresentedObject:[selectedPatch input]]];    
    }
    else {
        [inputPopUp setEnabled:NO];
        [inputPopUp selectItemAtIndex:-1];    
    }
}


- (IBAction)inputPopUpChanged:(id)sender
{
    [self setInput:[[inputPopUp selectedItem] representedObject] forPatch:selectedPatch];
}


- (void)setInput:(PYMIDIEndpoint*)input forPatch:(Patch*)patch
{
    PYMIDIEndpoint* oldInput = [patch input];
    if (oldInput == input) return;
    
    [patch setInput:input];
    [patchTable reloadData];
    if (patch == selectedPatch) [self setInputPopUp];
    
    [[[self undoManager] prepareWithInvocationTarget:self]
        setInput:oldInput forPatch:patch
    ];
}



#pragma mark Patch editing - Channel filter


- (void)buildFilterChannelControls
{
    NSButtonCell* buttonCell;
    int i;
    
    buttonCell = [[NSButtonCell alloc] init];
    [buttonCell setButtonType:NSSwitchButton];
    [buttonCell setTitle:@"16"];
    [filterChannelMatrix setPrototype:buttonCell];
    [filterChannelMatrix setCellSize:[buttonCell cellSize]];
    [filterChannelMatrix setIntercellSpacing:NSMakeSize(5,4)];
    [filterChannelMatrix setMode:NSTrackModeMatrix];
    [filterChannelMatrix renewRows:2 columns:8];
    [buttonCell release];
    
    for (i = 0; i < 8; i++) {
        buttonCell = [filterChannelMatrix cellAtRow:0 column:i];
        [buttonCell setTitle:[NSString stringWithFormat:@"%d", i+1]];
        [buttonCell setTag:i];
    }
    for (i = 0; i < 8; i++) {
        buttonCell = [filterChannelMatrix cellAtRow:1 column:i];
        [buttonCell setTitle:[NSString stringWithFormat:@"%d", i+9]];
        [buttonCell setTag:i+8];
    }
}


- (void)setFilterChannelControls
{
    int i;
    BOOL channelIsEnabled;
    
    if (selectedPatch != nil) {
        [filterChannelRadioButtons setEnabled:YES];
        [filterChannelRadioButtons selectCellWithTag:[selectedPatch shouldFilterChannel] ? 1 : 0];
        [filterChannelMatrix setEnabled:[selectedPatch shouldFilterChannel]];
        for (i = 0; i < 16; i++) {
            channelIsEnabled = ([selectedPatch channelMask] >> i) & 1;
            [[filterChannelMatrix cellWithTag:i] setState:channelIsEnabled ? NSOnState : NSOffState];
        }
    }
    else {
        [filterChannelRadioButtons setEnabled:NO];
        [filterChannelRadioButtons deselectAllCells];
        [filterChannelMatrix setEnabled:NO];
        [filterChannelMatrix deselectAllCells];
    }
}


- (IBAction)filterChannelRadioButtonsChanged:(id)sender
{
    [self setShouldFilterChannel:[[filterChannelRadioButtons selectedCell] tag] == 1 forPatch:selectedPatch];
}


- (void)setShouldFilterChannel:(BOOL)shouldFilterChannel forPatch:(Patch*)patch
{
    BOOL oldValue = [patch shouldFilterChannel];
    if (oldValue == shouldFilterChannel) return;
    
    [patch setShouldFilterChannel:shouldFilterChannel];
    [patchTable reloadData];
    if (patch == selectedPatch) [self setFilterChannelControls];
    
    [[[self undoManager] prepareWithInvocationTarget:self]
        setShouldFilterChannel:oldValue forPatch:patch
    ];
}


- (IBAction)filterChannelMatrixChanged:(id)sender
{
    int i;
    unsigned int channelMask = 0;
    
    for (i = 0; i < 16; i++) {
        if ([[filterChannelMatrix cellWithTag:i] state] == NSOnState)
            channelMask |= 1 << i;
    }
    
    [self setChannelMask:channelMask forPatch:selectedPatch];
}


- (void)setChannelMask:(unsigned int)channelMask forPatch:(Patch*)patch
{
    unsigned int oldMask = [patch channelMask];
    if (oldMask == channelMask) return;
    
    [patch setChannelMask:channelMask];
    [patchTable reloadData];
    if (patch == selectedPatch) [self setFilterChannelControls];
    
    [[[self undoManager] prepareWithInvocationTarget:self]
        setChannelMask:oldMask forPatch:patch
    ];

}



#pragma mark Patch editing - Channel remapping


- (void)buildRemapChannelControls
{
    int i;
    
    [remapChannelPopUp removeAllItems];
    for (i = 1; i <= 16; i++)
        [remapChannelPopUp addItemWithTitle:[NSString stringWithFormat:@"%d", i]];
}


- (void)setRemapChannelControls
{
    if (selectedPatch != nil) {
        [remapChannelButton setEnabled:YES];
        [remapChannelButton setState:[selectedPatch shouldRemapChannel] ? NSOnState : NSOffState];
        [remapChannelPopUp setEnabled:[selectedPatch shouldRemapChannel]];
        [remapChannelPopUp selectItemAtIndex:[selectedPatch remappingChannel] - 1];
    }
    else {
        [remapChannelButton setEnabled:NO];
        [remapChannelButton setState:NSOffState];
        [remapChannelPopUp setEnabled:NO];
        [remapChannelPopUp selectItemAtIndex:-1];
    }
}


- (IBAction)remapChannelButtonChanged:(id)sender
{
    [self setShouldRemapChannel:[remapChannelButton state] == NSOnState forPatch:selectedPatch];
}


- (void)setShouldRemapChannel:(BOOL)shouldRemapChannel forPatch:(Patch*)patch
{
    NSUndoManager* undoManager = [self undoManager];
    BOOL oldValue;
    
    oldValue = [patch shouldRemapChannel];
    
    [patch setShouldRemapChannel:shouldRemapChannel];
    [patchTable reloadData];
    if (patch == selectedPatch) [self setRemapChannelControls];
    
    [[undoManager prepareWithInvocationTarget:self]
        setShouldRemapChannel:oldValue forPatch:patch
    ];
}


- (IBAction)remapChannelPopUpChanged:(id)sender
{
    [self setRemappingChannel:(int)[remapChannelPopUp indexOfSelectedItem] + 1 forPatch:selectedPatch];
}


- (void)setRemappingChannel:(int)channel forPatch:(Patch*)patch
{
    int oldValue = [patch remappingChannel];
    if (oldValue == channel) return;
    
    [patch setRemappingChannel:channel];
    [patchTable reloadData];
    if (patch == selectedPatch) [self setRemapChannelControls];
    
    [[[self undoManager] prepareWithInvocationTarget:self]
        setRemappingChannel:oldValue forPatch:patch
    ];
}



#pragma mark Patch editing - Range filtering


- (void)buildFilterRangeControls
{
}


- (void)setFilterRangeControls
{
    PYMIDIManager* manager = [PYMIDIManager sharedInstance];
    
    if (selectedPatch != nil) {
        [filterRangeRadioButtons setEnabled:YES];
        if ([selectedPatch shouldFilterRange])
            [filterRangeRadioButtons selectCellWithTag:2];
        else if ([selectedPatch shouldAllowNotes])
            [filterRangeRadioButtons selectCellWithTag:0];
        else
            [filterRangeRadioButtons selectCellWithTag:1];
        [lowestAllowedNoteSlider setEnabled:[selectedPatch shouldFilterRange]];
        [lowestAllowedNoteSlider setIntValue:[selectedPatch lowestAllowedNote]];
        [lowestAllowedNoteField setEnabled:[selectedPatch shouldFilterRange]];
        [lowestAllowedNoteField setStringValue:[manager nameOfNote:[selectedPatch lowestAllowedNote]]];
        [lowestAllowedNoteStepper setEnabled:[selectedPatch shouldFilterRange]];
        [lowestAllowedNoteStepper setIntValue:[selectedPatch lowestAllowedNote]];
        [filterRangeLabelField setEnabled:[selectedPatch shouldFilterRange]];
        [highestAllowedNoteSlider setEnabled:[selectedPatch shouldFilterRange]];
        [highestAllowedNoteSlider setIntValue:[selectedPatch highestAllowedNote]];
        [highestAllowedNoteField setEnabled:[selectedPatch shouldFilterRange]];
        [highestAllowedNoteField setStringValue:[manager nameOfNote:[selectedPatch highestAllowedNote]]];
        [highestAllowedNoteStepper setEnabled:[selectedPatch shouldFilterRange]];
        [highestAllowedNoteStepper setIntValue:[selectedPatch highestAllowedNote]];
    }
    else {
        [filterRangeRadioButtons setEnabled:NO];
        [filterRangeRadioButtons deselectAllCells];
        [lowestAllowedNoteSlider setEnabled:NO];
        [lowestAllowedNoteSlider setIntValue:0];
        [lowestAllowedNoteField setEnabled:NO];
        [lowestAllowedNoteField setStringValue:@""];
        [lowestAllowedNoteStepper setEnabled:NO];
        [filterRangeLabelField setEnabled:NO];
        [highestAllowedNoteSlider setEnabled:NO];
        [highestAllowedNoteSlider setIntValue:127];
        [highestAllowedNoteField setEnabled:NO];
        [highestAllowedNoteField setStringValue:@""];
        [highestAllowedNoteStepper setEnabled:NO];
    }
}


- (IBAction)filterRangeRadioButtonsChanged:(id)sender
{
    switch ([[filterRangeRadioButtons selectedCell] tag]) {
    case 0:
        [self setShouldAllowNotes:YES forPatch:selectedPatch];
        [self setShouldFilterRange:NO forPatch:selectedPatch];
        break;
        
    case 1:
        [self setShouldAllowNotes:NO forPatch:selectedPatch];
        [self setShouldFilterRange:NO forPatch:selectedPatch];
        break;
        
    case 2:
        [self setShouldAllowNotes:YES forPatch:selectedPatch];
        [self setShouldFilterRange:YES forPatch:selectedPatch];
        break;
    }
}


- (void)setShouldAllowNotes:(BOOL)shouldAllowNotes forPatch:(Patch*)patch
{
    BOOL oldValue = [patch shouldAllowNotes];
    if (oldValue == shouldAllowNotes) return;
    
    [patch setShouldAllowNotes:shouldAllowNotes];
    [patchTable reloadData];
    if (patch == selectedPatch) {
        [self setFilterRangeControls];
        [self setTransposeControls];
    }
    
    [[[self undoManager] prepareWithInvocationTarget:self]
        setShouldAllowNotes:oldValue forPatch:patch
    ];
}


- (void)setShouldFilterRange:(BOOL)shouldFilterRange forPatch:(Patch*)patch
{
    BOOL oldValue = [patch shouldFilterRange];
    if (oldValue == shouldFilterRange) return;
    
    [patch setShouldFilterRange:shouldFilterRange];
    [patchTable reloadData];
    if (patch == selectedPatch) [self setFilterRangeControls];
    
    [[[self undoManager] prepareWithInvocationTarget:self]
        setShouldFilterRange:oldValue forPatch:patch
    ];
}



- (IBAction)lowestAllowedNoteSliderChanged:(id)sender
{
    [self setLowestAllowedNote:[lowestAllowedNoteSlider intValue] forPatch:selectedPatch];
}


- (IBAction)lowestAllowedNoteStepperChanged:(id)sender
{
    [self setLowestAllowedNote:[lowestAllowedNoteStepper intValue] forPatch:selectedPatch];
}


- (void)setLowestAllowedNote:(Byte)note forPatch:(Patch*)patch
{
    Byte oldNote = [patch lowestAllowedNote];
    if (oldNote == note) return;
    
    [patch setLowestAllowedNote:note];
    [patchTable reloadData];
    if (patch == selectedPatch) [self setFilterRangeControls];
    
    [[[self undoManager] prepareWithInvocationTarget:self]
        setLowestAllowedNote:oldNote forPatch:patch
    ];
   
}


- (IBAction)highestAllowedNoteSliderChanged:(id)sender
{
    [self setHighestAllowedNote:[highestAllowedNoteSlider intValue] forPatch:selectedPatch];
}


- (IBAction)highestAllowedNoteStepperChanged:(id)sender
{
    [self setHighestAllowedNote:[highestAllowedNoteStepper intValue] forPatch:selectedPatch];
}


- (void)setHighestAllowedNote:(Byte)note forPatch:(Patch*)patch
{
    Byte oldNote = [patch highestAllowedNote];
    if (oldNote == note) return;
    
    [patch setHighestAllowedNote:note];
    [patchTable reloadData];
    if (patch == selectedPatch) [self setFilterRangeControls];
    
    [[[self undoManager] prepareWithInvocationTarget:self]
        setHighestAllowedNote:oldNote forPatch:patch
    ];
   
}



#pragma mark Patch editing - Transposition


- (void)buildTransposeControls
{
}


- (void)setTransposeControls
{
    if (selectedPatch != nil) {
        [transposeButton setEnabled:[selectedPatch shouldAllowNotes]];
        [transposeButton setState:[selectedPatch shouldTranspose] ? NSOnState : NSOffState];
        [transposeDistanceSlider
            setEnabled:[selectedPatch shouldAllowNotes] && [selectedPatch shouldTranspose]];
        [transposeDistanceSlider setIntValue:[selectedPatch transposeDistance]];
        [transposeDistanceField
            setEnabled:[selectedPatch shouldAllowNotes] && [selectedPatch shouldTranspose]];
        [transposeDistanceField
            setStringValue:[NSString stringWithFormat:@"%+d", [selectedPatch transposeDistance]]];
        [transposeDistanceStepper
            setEnabled:[selectedPatch shouldAllowNotes] && [selectedPatch shouldTranspose]];
        [transposeDistanceStepper setIntValue:[selectedPatch transposeDistance]];
    }
    else {
        [transposeButton setEnabled:NO];
        [transposeButton setState:NSOffState];
        [transposeDistanceSlider setEnabled:NO];
        [transposeDistanceSlider setIntValue:0];
        [transposeDistanceField setEnabled:NO];
        [transposeDistanceField setStringValue:@""];
        [transposeDistanceStepper setEnabled:NO];
    }
}


- (IBAction)transposeButtonChanged:(id)sender
{
    [self setShouldTranspose:[transposeButton state] == NSOnState forPatch:selectedPatch];
}


- (void)setShouldTranspose:(BOOL)shouldTranspose forPatch:(Patch*)patch
{
    NSUndoManager* undoManager = [self undoManager];
    Byte oldValue;
    
    oldValue = [patch shouldTranspose];
    
    [patch setShouldTranspose:shouldTranspose];
    [patchTable reloadData];
    if (patch == selectedPatch) [self setTransposeControls];
    
    [[undoManager prepareWithInvocationTarget:self]
        setShouldTranspose:oldValue forPatch:patch
    ];
}

- (IBAction)transposeDistanceSliderChanged:(id)sender
{
    [self setTransposeDistance:[transposeDistanceSlider intValue] forPatch:selectedPatch];
}


- (IBAction)transposeDistanceStepperChanged:(id)sender
{
    [self setTransposeDistance:[transposeDistanceStepper intValue] forPatch:selectedPatch];
}


- (void)setTransposeDistance:(int)distance forPatch:(Patch*)patch
{
    Byte oldDistance = [patch transposeDistance];
    if (oldDistance == distance) return;
    
    [patch setTransposeDistance:distance];
    [patchTable reloadData];
    if (patch == selectedPatch) [self setTransposeControls];
    
    [[[self undoManager] prepareWithInvocationTarget:self]
        setTransposeDistance:oldDistance forPatch:patch
    ];
}



#pragma mark Patch editing - Clock


- (void)buildTransmitClockControls
{
}

- (void)setTransmitClockControls
{
    if (selectedPatch != nil) {
        [transmitClockButton setEnabled:YES];
        [transmitClockButton setState:[selectedPatch shouldTransmitClock] ? NSOnState : NSOffState];
    }
    else {
        [transmitClockButton setEnabled:NO];
        [transmitClockButton setState:NSOffState];
    }
}

- (IBAction)transmitClockButtonChanged:(id)sender
{
    [self setShouldTransmitClock:[transmitClockButton state] == NSOnState forPatch:selectedPatch];
}


- (void)setShouldTransmitClock:(BOOL)state forPatch:(Patch*)patch
{
    NSUndoManager* undoManager = [self undoManager];
    BOOL oldState;
    
    oldState = [patch shouldTransmitClock];
    
    [patch setShouldTransmitClock:state];
    [patchTable reloadData];
    if (patch == selectedPatch) [self setTransmitClockControls];
    
    [[undoManager prepareWithInvocationTarget:self]
        setShouldTransmitClock:oldState forPatch:patch
    ];
}


- (void)buildOutputPopUp
{
    PYMIDIManager*	manager = [PYMIDIManager sharedInstance];
    NSArray*		realDestinations;
    NSEnumerator*	enumerator;
    PYMIDIEndpoint*	output;

    [outputPopUp removeAllItems];

    realDestinations = [manager realDestinations];
    
    enumerator = [realDestinations objectEnumerator];
    while (output = [enumerator nextObject]) {
        [outputPopUp addItemWithTitle:[output displayName]];
        [[outputPopUp lastItem] setRepresentedObject:output];
    }

    if ([realDestinations count] > 0 && [virtualSourceArray count] > 0)
        [[outputPopUp menu] addItem:[NSMenuItem separatorItem]];
   
    enumerator = [virtualSourceArray objectEnumerator];
    while (output = [enumerator nextObject]) {
        [outputPopUp addItemWithTitle:[output displayName]];
        [[outputPopUp lastItem] setRepresentedObject:output];
    }
    
    if ([realDestinations count] > 0 || [virtualSourceArray count] > 0)
        [[outputPopUp menu] addItem:[NSMenuItem separatorItem]];
        
    [outputPopUp addItemWithTitle:@"Edit Virtual Outputs..."];
    [[outputPopUp lastItem] setTarget:self];
    [[outputPopUp lastItem] setAction:@selector(editVirtualOutputs:)];
}


- (void)setOutputPopUp
{
    if (selectedPatch != nil) {
        [outputPopUp setEnabled:YES];
        [outputPopUp selectItemAtIndex:[outputPopUp indexOfItemWithRepresentedObject:[selectedPatch output]]];
    }
    else {
        [outputPopUp setEnabled:NO];
        [outputPopUp selectItemAtIndex:-1];
    }
}


- (IBAction)outputPopUpChanged:(id)sender
{
    [self setOutput:[[outputPopUp selectedItem] representedObject] forPatch:selectedPatch];
}


- (void)setOutput:(PYMIDIEndpoint*)output forPatch:(Patch*)patch
{
    PYMIDIEndpoint* oldOutput = [patch output];
    if (oldOutput == output) return;
    
    [patch setOutput:output];
    [patchTable reloadData];
    if (patch == selectedPatch) [self setOutputPopUp];
    
    [[[self undoManager] prepareWithInvocationTarget:self]
        setOutput:oldOutput forPatch:patch
    ];
}



#pragma mark Virtual endpoints


- (IBAction)editVirtualInputs:(id)sender
{
    [self setInputPopUp];
    
    [virtualEndpointTabView selectTabViewItemAtIndex:0];

    // Put everything that happens in the panel into its own undo group
    [[self undoManager] beginUndoGrouping];
    
    panelWasOpenedToInputs = YES;
    
    [[NSApplication sharedApplication]
        beginSheet:virtualEndpointPanel
        modalForWindow:documentWindow
        modalDelegate:self
        didEndSelector:@selector(endpointPanelDidEnd:returnCode:contextInfo:)
        contextInfo:nil
    ];
}


- (IBAction)editVirtualOutputs:(id)sender
{
    [self setOutputPopUp];
    
    [virtualEndpointTabView selectTabViewItemAtIndex:1];
    
    // Put everything that happens in the panel into its own undo group
    [[self undoManager] beginUndoGrouping];

    panelWasOpenedToInputs = NO;
    
    [[NSApplication sharedApplication]
        beginSheet:virtualEndpointPanel
        modalForWindow:documentWindow
        modalDelegate:self
        didEndSelector:@selector(endpointPanelDidEnd:returnCode:contextInfo:)
        contextInfo:nil
    ];
}


- (IBAction)newInputButtonPressed:(id)sender
{
    NSString* baseName = [NSString stringWithFormat:@"%@ input",
        [[[self displayName] lastPathComponent] stringByDeletingPathExtension]
    ];
    
    [inputTableDataSource tableView:inputTable newEndpointWithName:baseName];
    
    // Set up the newly created endpoint for editing
    [inputTable selectRow:[inputTable numberOfRows]-1 byExtendingSelection:NO];
    [inputTable editColumn:0 row:[inputTable selectedRow] withEvent:nil select:YES];
}
    


- (IBAction)newOutputButtonPressed:(id)sender
{
    NSString* baseName = [NSString stringWithFormat:@"%@ output",
        [[[self displayName] lastPathComponent] stringByDeletingPathExtension]
    ];

    [[outputTable dataSource] tableView:outputTable newEndpointWithName:baseName];

    // Set up the newly created endpoint for editing
    [outputTable selectRow:[outputTable numberOfRows]-1 byExtendingSelection:NO];
    [outputTable editColumn:0 row:[outputTable selectedRow] withEvent:nil select:YES];
}



- (IBAction)endpointPanelButtonPressed:(id)sender
{
    if ([virtualEndpointPanel makeFirstResponder:nil]) {        
        [virtualEndpointPanel orderOut:self];
        [[NSApplication sharedApplication] endSheet:virtualEndpointPanel returnCode:0];
    }
}


- (void)endpointPanelDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo
{
    NSInteger tab = [virtualEndpointTabView indexOfTabViewItem:[virtualEndpointTabView selectedTabViewItem]];
    
    if (panelWasOpenedToInputs) {
        if (tab == 0 && [inputTable selectedRow] != -1) {
            PYMIDIEndpoint* input = [virtualDestinationArray objectAtIndex:[inputTable selectedRow]];
            [self setInput:input forPatch:selectedPatch];
        }
    }
    else {
        if (tab == 1 && [outputTable selectedRow] != -1) {
            PYMIDIEndpoint* output = [virtualSourceArray objectAtIndex:[outputTable selectedRow]];
            [self setOutput:output forPatch:selectedPatch];;
        }
    }

    [[self undoManager] endUndoGrouping];
}


@end
