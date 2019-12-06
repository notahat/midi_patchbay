#import <AppKit/AppKit.h>
#import <CoreMIDI/CoreMIDI.h>

@class PYMIDIEndpointDescriptor;
@class PYMIDIEndpoint;


@interface PYMIDIManager : NSObject {
    BOOL			notificationsEnabled;
    MIDIClientRef	midiClientRef;

    NSMutableArray*	realSourceArray;
    NSMutableArray* realDestinationArray;

    NSArray*		noteNamesArray;
}

+ (PYMIDIManager*)sharedInstance;

- (PYMIDIManager*)init;

- (MIDIClientRef)midiClientRef;

#pragma mark NOTIFICATION HANDLING

- (void)disableNotifications;
- (void)enableNotifications;

#pragma mark REAL MIDI SOURCES

- (NSArray*)realSources;
- (NSArray*)realSourcesOnlineOrInUse;
- (PYMIDIEndpoint*)realSourceWithDescriptor:(PYMIDIEndpointDescriptor*)descriptor;

#pragma mark REAL MIDI DESTINATIONS

- (NSArray*)realDestinations;
- (NSArray*)realDestinationsOnlineOrInUse;
- (PYMIDIEndpoint*)realDestinationWithDescriptor:(PYMIDIEndpointDescriptor*)descriptor;

#pragma mark NOTE NAMES

- (NSString*)nameOfNote:(Byte)note;

@end
