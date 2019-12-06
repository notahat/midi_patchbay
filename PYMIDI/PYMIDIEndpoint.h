#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import <AudioToolbox/AudioToolbox.h>

@class PYMIDIEndpointDescriptor;


@interface PYMIDIEndpoint : NSObject <NSCoding> {
    MIDIEndpointRef		midiEndpointRef;
    NSMutableString*			name;
    SInt32				uniqueID;
    NSMutableString*			displayName;
    
    NSMutableSet*		receivers;
    NSMutableSet*		senders;
    // NSMutableSet*    midiControllers;
}


#pragma mark INITIALISATION

- (id)init;
- (id)initWithName:(NSString*)newName uniqueID:(SInt32)newUniqueID;
- (id)initWithMIDIEndpointRef:(MIDIEndpointRef)newMIDIEndpointRef;
- (void)dealloc;

#pragma mark ARCHIVING

- (id)initWithCoder:(NSCoder*)coder;
- (void)encodeWithCoder:(NSCoder*)coder;

- (PYMIDIEndpointDescriptor*)descriptor;


#pragma mark PROPERTIES

/* Resets the name and uniqueID from the MIDIEndpointRef */
- (void)setPropertiesFromMIDIEndpoint;

- (NSMutableString*)name;
- (BOOL)setName:(NSString*)newName;

- (NSMutableString*)displayName;
- (NSComparisonResult)compareByDisplayName:(PYMIDIEndpoint*)endpoint;

- (SInt32)uniqueID;
- (BOOL)setUniqueID:(SInt32)newUniqueID;

- (MIDIEndpointRef)midiEndpointRef;

- (BOOL)isIACBus;

- (BOOL)isOnline;
- (BOOL)isOffline;
- (BOOL)isInUse;
- (BOOL)isOnlineOrInUse;


#pragma mark SENDING & RECEIVING

- (void)addReceiver:(id)receiver;
- (void)removeReceiver:(id)receiver;
- (void)addSender:(id)sender;
- (void)removeSender:(id)sender;
// - (void)connectToMIDIController:(AUMIDIControllerRef)controller;
// - (void)disconnectFromMIDIController:(AUMIDIControllerRef)controller;
- (void)processMIDIPacketList:(const MIDIPacketList*)packetList sender:(id)sender;


#pragma mark IO

/* Override these to do the hard work */
- (BOOL)ioIsRunning;
- (void)startIO;
- (void)stopIO;


@end
