#import <PYMIDI/PYMIDIEndpoint.h>
#import <PYMIDI/PYMIDIVirtualEndpoint.h>


@interface PYMIDIVirtualDestination : PYMIDIVirtualEndpoint {
}

- (id)initWithName:(NSString*)newName;

- (void)processMIDIPacketList:(const MIDIPacketList*)packetList sender:(id)sender;

@end