#import <PYMIDI/PYMIDIVirtualSource.h>
#import <PYMIDI/PYMIDIUtils.h>
#import <PYMIDI/PYMIDIManager.h>


@implementation PYMIDIVirtualSource


- (id)initWithName:(NSString*)newName
{
    PYMIDIManager*		manager = [PYMIDIManager sharedInstance];
    MIDIEndpointRef		newEndpoint;
    OSStatus			error;
    SInt32				newUniqueID;
    
    // This makes sure that we don't get notified about this endpoint until after
    // we're done creating it.
    [manager disableNotifications];
    
    MIDISourceCreate ([manager midiClientRef], (CFStringRef)newName, &newEndpoint);
    
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
    if (ioIsRunning) MIDIReceived (midiEndpointRef, packetList);
}


@end
