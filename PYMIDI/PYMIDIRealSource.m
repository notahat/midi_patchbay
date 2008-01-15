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
    
    [self release];
    return [[manager realSourceWithDescriptor:descriptor] retain];
}



- (void)syncWithMIDIEndpoint
{
    MIDIEndpointRef newEndpointRef;
    
    if (midiEndpointRef && PYMIDIDoesSourceStillExist (midiEndpointRef))
        newEndpointRef = midiEndpointRef;
    else
        newEndpointRef = NULL;

    if (newEndpointRef == NULL)  newEndpointRef = PYMIDIGetSourceByUniqueID (uniqueID);
    if (newEndpointRef == NULL)  newEndpointRef = PYMIDIGetSourceByName (name);

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

    MIDIInputPortCreate (
        [[PYMIDIManager sharedInstance] midiClientRef], CFSTR("PYMIDIRealSource"),
        midiReadProc, (void*)self, &midiPortRef
    );
    MIDIPortConnectSource (midiPortRef, midiEndpointRef, nil);
}


- (void)stopIO
{
    if (midiPortRef == nil) return;
    
    MIDIPortDisconnectSource (midiPortRef, midiEndpointRef);
    MIDIPortDispose (midiPortRef);
    midiPortRef = nil;
}


- (void)processMIDIPacketList:(const MIDIPacketList*)packetList sender:(id)sender
{
    // I'm not sure how expensive creating an auto release pool here is.
    // I'm hoping it's cheap, meaning it won't add much latency.  It also
    // means that we can do memory allocation freely in the processing and
    // it will all get automatically cleaned up once we've passed the data
    // on, which is a win.
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSEnumerator* enumerator = [receivers objectEnumerator];
    id receiver;

    while (receiver = [[enumerator nextObject] nonretainedObjectValue])
        [receiver processMIDIPacketList:packetList sender:self];
        
    [pool release];
}


static void
midiReadProc (const MIDIPacketList* packetList, void* createRefCon, void* connectRefConn)
{
    PYMIDIRealSource* source = (PYMIDIRealSource*)createRefCon;
    [source processMIDIPacketList:packetList sender:source];
}


@end
