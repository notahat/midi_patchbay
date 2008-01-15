#import <PYMIDI/PYMIDIVirtualDestination.h>
#import <PYMIDI/PYMIDIUtils.h>
#import <PYMIDI/PYMIDIManager.h>


@implementation PYMIDIVirtualDestination


static void midiReadProc (const MIDIPacketList* packetList, void* createRefCon, void* connectRefConn);


- (id)initWithName:(NSString*)newName
{
    PYMIDIManager*	manager = [PYMIDIManager sharedInstance];
    MIDIEndpointRef newEndpoint;
    OSStatus		error;
    SInt32			newUniqueID;
    
    // This makes sure that we don't get notified about this endpoint until after
    // we're done creating it.
    [manager disableNotifications];
    
    MIDIDestinationCreate ([manager midiClientRef], (CFStringRef)newName, midiReadProc, self, &newEndpoint);
    
    // This code works around a bug in OS X 10.1 that causes
    // new sources/destinations to be created without unique IDs.
    error = MIDIObjectGetIntegerProperty (newEndpoint, kMIDIPropertyUniqueID, &newUniqueID);
    if (error == kMIDIUnknownProperty) {
        newUniqueID = PYMIDIAllocateUniqueID();
        MIDIObjectSetIntegerProperty (newEndpoint, kMIDIPropertyUniqueID, newUniqueID);
    }
    
    MIDIObjectSetIntegerProperty (newEndpoint, CFSTR("PYMIDIOwnerPID"), [[NSProcessInfo processInfo] processIdentifier]);

    [manager enableNotifications];
    
    self = [super initWithMIDIEndpointRef:newEndpoint];

    ioIsRunning = NO;
    
    return self;
}


- (void)processMIDIPacketList:(const MIDIPacketList*)packetList sender:(id)sender
{
    NSAutoreleasePool* pool;
    NSEnumerator* enumerator;
    id receiver;

    if (!ioIsRunning) return;

    // I'm not sure how expensive creating an auto release pool here is.
    // I'm hoping it's cheap, meaning it won't add much latency.  It also
    // means that we can do memory allocation freely in the processing and
    // it will all get automatically cleaned up once we've passed the data
    // on, which is a win.
    pool = [[NSAutoreleasePool alloc] init];
    
    enumerator = [receivers objectEnumerator];
    while (receiver = [[enumerator nextObject] nonretainedObjectValue])
        [receiver processMIDIPacketList:packetList sender:self];
        
    [pool release];
}


static void
midiReadProc (const MIDIPacketList* packetList, void* createRefCon, void* connectRefConn)
{
    PYMIDIVirtualDestination* destination = (PYMIDIVirtualDestination*)createRefCon;
    [destination processMIDIPacketList:packetList sender:destination];
}


@end
