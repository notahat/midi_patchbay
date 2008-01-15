#import <PYMIDI/PYMIDIRealDestination.h>
#import <PYMIDI/PYMIDIUtils.h>
#import <PYMIDI/PYMIDIManager.h>
#import <PYMIDI/PYMIDIEndpointDescriptor.h>


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
        newEndpointRef = NULL;

    if (newEndpointRef == NULL) newEndpointRef = PYMIDIGetDestinationByUniqueID (uniqueID);
    if (newEndpointRef == NULL) newEndpointRef = PYMIDIGetDestinationByName (name);
    
    if (midiEndpointRef != newEndpointRef) {
        [self stopIO];
        midiEndpointRef = newEndpointRef;
        if ([self isInUse]) [self startIO];
    }
    
    [self setPropertiesFromMIDIEndpoint];
}


- (void)startIO
{
    if (midiEndpointRef == nil || midiPortRef != nil) return;

    MIDIOutputPortCreate (
        [[PYMIDIManager sharedInstance] midiClientRef], CFSTR("PYMIDIRealDestination"),
        &midiPortRef
    );
}


- (void)stopIO
{
    if (midiPortRef == nil) return;
    
    MIDIPortDispose (midiPortRef);
    midiPortRef = nil;
}


- (void)processMIDIPacketList:(const MIDIPacketList*)packetList sender:(id)sender
{
    if (midiEndpointRef != NULL && midiPortRef != NULL)
        MIDISend (midiPortRef, midiEndpointRef, packetList);
}


@end
