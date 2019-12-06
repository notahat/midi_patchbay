#import <PYMIDI/PYMIDIRealSource.h>
#import <PYMIDI/PYMIDIUtils.h>
#import <PYMIDI/PYMIDIManager.h>
#import <PYMIDI/PYMIDIEndpointDescriptor.h>


@implementation PYMIDIRealSource


static void midiReadProc (const MIDIPacketList* packetList, void* createRefCon, void* connectRefConn);


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

    return (PYMIDIRealSource *)[manager realSourceWithDescriptor:descriptor];
}



- (void)syncWithMIDIEndpoint
{
    MIDIEndpointRef newEndpointRef;
    
    if (midiEndpointRef && PYMIDIDoesSourceStillExist (midiEndpointRef))
        newEndpointRef = midiEndpointRef;
    else
        newEndpointRef = 0;

    if (!newEndpointRef)  newEndpointRef = PYMIDIGetSourceByUniqueID (uniqueID);
    if (!newEndpointRef)  newEndpointRef = PYMIDIGetSourceByName (name);

    if (midiEndpointRef != newEndpointRef) {
        [self stopIO];
        midiEndpointRef = newEndpointRef;
        if ([self isInUse]) [self startIO];
    }

    [self setPropertiesFromMIDIEndpoint];
}


- (void)startIO
{
    if (!midiEndpointRef || midiPortRef ) return;

    MIDIInputPortCreate (
        [[PYMIDIManager sharedInstance] midiClientRef], CFSTR("PYMIDIRealSource"),
						 midiReadProc, (__bridge void*)self, &midiPortRef
    );
    MIDIPortConnectSource (midiPortRef, midiEndpointRef, nil);
}


- (void)stopIO
{
    if (!midiPortRef) return;
    
    MIDIPortDisconnectSource (midiPortRef, midiEndpointRef);
    MIDIPortDispose (midiPortRef);
    midiPortRef = 0;
}


- (void)processMIDIPacketList:(const MIDIPacketList*)packetList sender:(id)sender
{
    // I'm not sure how expensive creating an auto release pool here is.
    // I'm hoping it's cheap, meaning it won't add much latency.  It also
    // means that we can do memory allocation freely in the processing and
    // it will all get automatically cleaned up once we've passed the data
    // on, which is a win.
	@autoreleasepool {
		NSEnumerator* enumerator = [receivers objectEnumerator];
		id receiver;

		while ((receiver = [[enumerator nextObject] nonretainedObjectValue]))
			[receiver processMIDIPacketList:packetList sender:self];

	}
}


static void
midiReadProc (const MIDIPacketList* packetList, void* createRefCon, void* connectRefConn)
{
	PYMIDIRealSource* source = (__bridge PYMIDIRealSource*)createRefCon;
    [source processMIDIPacketList:packetList sender:source];
}


@end
