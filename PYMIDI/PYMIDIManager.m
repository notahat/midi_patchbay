#import "PYMIDI/PYMIDIManager.h"
#import <PYMIDI/PYMIDIUtils.h>
#import <PYMIDI/PYMIDIEndpoint.h>
#import <PYMIDI/PYMIDIEndpointSet.h>
#import <PYMIDI/PYMIDIRealEndpoint.h>
#import <PYMIDI/PYMIDIRealSource.h>
#import <PYMIDI/PYMIDIRealDestination.h>


@interface PYMIDIManager(private)

- (void)processMIDINotification:(const MIDINotification*)message;

- (void)updateRealSources;
- (PYMIDIEndpoint*)realSourceWithMIDIEndpointRef:(MIDIEndpointRef)midiEndpointRef;
- (void)updateRealDestinations;
- (PYMIDIEndpoint*)realDestinationWithMIDIEndpointRef:(MIDIEndpointRef)midiEndpointRef;

- (void)buildNoteNamesArray;

@end


@implementation PYMIDIManager


static void midiNotifyProc (const MIDINotification* message, void* refCon);


+ (PYMIDIManager*)sharedInstance
{
    static PYMIDIManager* sharedInstance = nil;

    if (sharedInstance == nil) sharedInstance = [[PYMIDIManager alloc] init];
    
    return sharedInstance;
}


- (PYMIDIManager*)init
{
    notificationsEnabled = NO;
    
    MIDIClientCreate (CFSTR("PYMIDIManager"), midiNotifyProc, (void*)self, &midiClientRef);

    realSourceArray = [[NSMutableArray alloc] init];
    realDestinationArray = [[NSMutableArray alloc] init];
    
    [self updateRealSources];
    [self updateRealDestinations];

    [self buildNoteNamesArray];
        
    notificationsEnabled = YES;
            
    return self;
}


- (void)dealloc
{
    [realSourceArray release];
    [realDestinationArray release];
    
    [noteNamesArray release];
    
    [super dealloc];
}


- (MIDIClientRef)midiClientRef
{
    return midiClientRef;
}



#pragma mark NOTIFICATION HANDLING


- (void)disableNotifications
{
    notificationsEnabled = NO;
}

- (void)enableNotifications
{
    notificationsEnabled = YES;
}


- (void)processMIDINotification:(const MIDINotification*)message
{
    static BOOL isHandlingNotification = NO;
    static BOOL shouldRetryWhenDone    = NO;
    
    if (isHandlingNotification) {
        shouldRetryWhenDone = YES;
        return;
    }
    
    do {
        isHandlingNotification = YES;
        shouldRetryWhenDone    = NO;
        
        switch (message->messageID) {
        case kMIDIMsgSetupChanged:
            if (notificationsEnabled) {
                [self updateRealSources];
                [self updateRealDestinations];
        
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PYMIDISetupChanged" object:self];
            }
            break;
        }
        
        isHandlingNotification = NO;
    } while (shouldRetryWhenDone);
}


static void
midiNotifyProc (const MIDINotification* message, void* refCon)
{
    PYMIDIManager* manager = (PYMIDIManager*)refCon;
    [manager processMIDINotification:message];
}



#pragma mark REAL MIDI SOURCES


- (void)updateRealSources
{
    NSEnumerator*			enumerator;
    PYMIDIRealEndpoint*		endpoint;
    
    // Sync up all the known MIDI endpoints with CoreMIDI
    enumerator = [realSourceArray objectEnumerator];
    while (endpoint = [enumerator nextObject])
        [endpoint syncWithMIDIEndpoint];
    
    // Find any non-virtual endpoints that we don't already know about
    int i;
    int count = MIDIGetNumberOfSources();
    for (i = 0; i < count; i++) {
        MIDIEndpointRef midiEndpointRef = MIDIGetSource (i);
        
        // If this endpoint is real and previously unknown then add it to our list
        if (!PYMIDIIsEndpointLocalVirtual (midiEndpointRef) &&
            [self realSourceWithMIDIEndpointRef:midiEndpointRef] == nil)
        {
            endpoint = [[PYMIDIRealSource alloc] initWithMIDIEndpointRef:midiEndpointRef];
            [realSourceArray addObject:endpoint];
        }
    }
    
    // Keep our endpoints sorted
    [realSourceArray sortUsingSelector:@selector(compareByDisplayName:)];
}


- (PYMIDIEndpoint*)realSourceWithMIDIEndpointRef:(MIDIEndpointRef)midiEndpointRef
{
    PYMIDIEndpoint* endpoint;
    
    NSEnumerator* enumerator = [realSourceArray objectEnumerator];
    while ((endpoint = [enumerator nextObject]) && [endpoint midiEndpointRef] != midiEndpointRef);
    
    return endpoint;
}


- (NSArray*)realSources
{
    return realSourceArray;
}


- (NSArray*)realSourcesOnlineOrInUse
{
    return [realSourceArray filteredArrayUsingSelector:@selector(isOnlineOrInUse)];
}



- (PYMIDIEndpoint*)realSourceWithDescriptor:(PYMIDIEndpointDescriptor*)descriptor
{
    PYMIDIEndpointSet*	endpointSet;
    PYMIDIEndpoint*		endpoint;
    
    endpointSet = [PYMIDIEndpointSet endpointSetWithArray:realSourceArray];
    endpoint = [endpointSet endpointWithDescriptor:descriptor];
    
    // Create a placeholder if no endpoint matches the descriptor
    if (endpoint == nil) {
        endpoint = [[PYMIDIRealSource alloc] initWithDescriptor:descriptor];
        [realSourceArray addObject:endpoint];
        [endpoint release];
    }
    
    return endpoint;
}



#pragma mark REAL MIDI DESTINATIONS


- (void)updateRealDestinations
{
    NSEnumerator*			enumerator;
    PYMIDIRealEndpoint*		endpoint;
    
    // Sync up all the known MIDI endpoints with CoreMIDI
    enumerator = [realDestinationArray objectEnumerator];
    while (endpoint = [enumerator nextObject])
        [endpoint syncWithMIDIEndpoint];
    
    // Find any non-virtual endpoints that we don't already know about
    int i;
    int count = MIDIGetNumberOfDestinations();
    for (i = 0; i < count; i++) {
        MIDIEndpointRef midiEndpointRef = MIDIGetDestination (i);
        
        // If this endpoint is real and previously unknown then add it to our list
        if (!PYMIDIIsEndpointLocalVirtual (midiEndpointRef) &&
            [self realDestinationWithMIDIEndpointRef:midiEndpointRef] == nil)
        {
            endpoint = [[PYMIDIRealDestination alloc] initWithMIDIEndpointRef:midiEndpointRef];
            [realDestinationArray addObject:endpoint];
        }
    }
    
    // Keep our endpoints sorted
    [realDestinationArray sortUsingSelector:@selector(compareByDisplayName:)];
}


- (PYMIDIEndpoint*)realDestinationWithMIDIEndpointRef:(MIDIEndpointRef)midiEndpointRef
{
    PYMIDIEndpoint* endpoint;
    
    NSEnumerator* enumerator = [realDestinationArray objectEnumerator];
    while ((endpoint = [enumerator nextObject]) && [endpoint midiEndpointRef] != midiEndpointRef);
    
    return endpoint;
}


- (NSArray*)realDestinations
{
    return realDestinationArray;
}


- (NSArray*)realDestinationsOnlineOrInUse
{
    return [realDestinationArray filteredArrayUsingSelector:@selector(isOnlineOrInUse)];
}



- (PYMIDIEndpoint*)realDestinationWithDescriptor:(PYMIDIEndpointDescriptor*)descriptor
{
    PYMIDIEndpointSet*	endpointSet;
    PYMIDIEndpoint*		endpoint;
    
    endpointSet = [PYMIDIEndpointSet endpointSetWithArray:realDestinationArray];
    endpoint = [endpointSet endpointWithDescriptor:descriptor];
    
    // Create a placeholder if no endpoint matches the descriptor
    if (endpoint == nil) {
        endpoint = [[PYMIDIRealDestination alloc] initWithDescriptor:descriptor];
        [realDestinationArray addObject:endpoint];
        [endpoint release];
    }
    
    return endpoint;
}



#pragma mark NOTE NAMES


- (void)buildNoteNamesArray
{
    NSMutableArray* tempNoteNamesArray;
    
    int i, octave, note;
    char* noteName[] = {
        "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"
    };
    
    tempNoteNamesArray = [NSMutableArray arrayWithCapacity:128];
    
    for (i = 0; i < 128; i++) {
        octave = i / 12;
        note   = i % 12;
        
        [tempNoteNamesArray addObject:[NSString stringWithFormat:@"%s%d", noteName[note], octave-1]];
    }
    
    noteNamesArray = [[NSArray alloc] initWithArray:tempNoteNamesArray];
}


- (NSString*)nameOfNote:(Byte)note
{
    return [noteNamesArray objectAtIndex:note];
}






@end