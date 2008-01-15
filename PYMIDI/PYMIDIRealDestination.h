#import <PYMIDI/PYMIDIEndpoint.h>
#import <PYMIDI/PYMIDIRealEndpoint.h>


@interface PYMIDIRealDestination : PYMIDIRealEndpoint {
}

- (id)initWithCoder:(NSCoder*)coder;

- (void)syncWithMIDIEndpoint;

- (void)startIO;
- (void)stopIO;
- (void)processMIDIPacketList:(const MIDIPacketList*)packetList sender:(id)sender;

@end