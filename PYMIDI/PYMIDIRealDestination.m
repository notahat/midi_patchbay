#import "PYMIDI/PYMIDIRealDestination.h"
#import "PYMIDI/PYMIDIUtils.h"
#import "PYMIDI/PYMIDIManager.h"
#import "PYMIDI/PYMIDIEndpointDescriptor.h"


@implementation PYMIDIRealDestination


- (id)initWithCoder:(NSCoder*)coder
{
    PYMIDIManager*				manager = [PYMIDIManager sharedInstance];
    NSString*					newName;
    SInt32						newUniqueID;
    PYMIDIEndpointDescriptor*	descriptor;

    self = [super initWithCoder:coder];
    
    newName     = [coder decodeObjectForKey:@"name"];
    newUniqueID = [coder decodeInt32ForKey:@"uniqueID"];
    
    descriptor = [PYMIDIEndpointDescriptor descriptorWithName:newName uniqueID:newUniqueID];
    
    [self release];
    return [[manager realDestinationWithDescriptor:descriptor] retain];
}    


- (void)syncWithMIDIEndpoint
{
    MIDIEndpointRef newEndpointRef;
    
    if (midiEndpointRef && PYMIDIDoesDestinationStillExist (midiEndpointRef))
        newEndpointRef = midiEndpointRef;
    else
        newEndpointRef = 0;

    if (newEndpointRef == 0) newEndpointRef = PYMIDIGetDestinationByUniqueID (uniqueID);
    if (newEndpointRef == 0) newEndpointRef = PYMIDIGetDestinationByName (name);
    
    if (midiEndpointRef != newEndpointRef) {
        [self stopIO];
        midiEndpointRef = newEndpointRef;
        if ([self isInUse]) [self startIO];
    }
    
    [self setPropertiesFromMIDIEndpoint];
}


- (void)startIO
{
    if (midiEndpointRef == 0 || midiPortRef != 0) return;

    MIDIOutputPortCreate (
        [[PYMIDIManager sharedInstance] midiClientRef], CFSTR("PYMIDIRealDestination"),
        &midiPortRef
    );
}


- (void)stopIO
{
    if (midiPortRef == 0) return;
    
    MIDIPortDispose (midiPortRef);
    midiPortRef = 0;
}


- (void)processMIDIPacketList:(const MIDIPacketList*)packetList sender:(id)sender
{
    if (midiEndpointRef != 0 && midiPortRef != 0)
        MIDISend (midiPortRef, midiEndpointRef, packetList);
}


@end
