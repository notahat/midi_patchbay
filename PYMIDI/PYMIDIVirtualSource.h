#import <PYMIDI/PYMIDIEndpoint.h>
#import <PYMIDI/PYMIDIVirtualEndpoint.h>


@interface PYMIDIVirtualSource : PYMIDIVirtualEndpoint {
}

- (id)initWithName:(NSString*)name;

- (void)processMIDIPacketList:(const MIDIPacketList*)packetList sender:(id)sender;

@end