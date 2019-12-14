#import <AppKit/AppKit.h>
#import <CoreMIDI/CoreMIDI.h>

@class PYMIDIEndpointDescriptor;
@class PYMIDIRealDestination;
@class PYMIDIRealSource;


@interface PYMIDIManager : NSObject {
    BOOL			notificationsEnabled;
    MIDIClientRef	midiClientRef;

    NSMutableArray*	realSourceArray;
    NSMutableArray* realDestinationArray;

    NSArray*		noteNamesArray;
}

+ (PYMIDIManager*)sharedInstance;

- (PYMIDIManager*)init;
- (void)dealloc;

- (MIDIClientRef)midiClientRef;

#pragma mark NOTIFICATION HANDLING

- (void)disableNotifications;
- (void)enableNotifications;

#pragma mark REAL MIDI SOURCES

- (NSArray*)realSources;
- (NSArray*)realSourcesOnlineOrInUse;
- (PYMIDIRealSource*)realSourceWithDescriptor:(PYMIDIEndpointDescriptor*)descriptor;

#pragma mark REAL MIDI DESTINATIONS

- (NSArray*)realDestinations;
- (NSArray*)realDestinationsOnlineOrInUse;
- (PYMIDIRealDestination*)realDestinationWithDescriptor:(PYMIDIEndpointDescriptor*)descriptor;

#pragma mark NOTE NAMES

- (NSString*)nameOfNote:(Byte)note;

@end
