#import <PYMIDI/PYMIDIEndpoint.h>

@class PYMIDIEndpointDescriptor;


@interface PYMIDIRealEndpoint : PYMIDIEndpoint {
    MIDIPortRef		midiPortRef;
}

/* These should only be called by PYMIDIManager */
- (id)initWithMIDIEndpointRef:(MIDIEndpointRef)newMIDIEndpointRef;
- (id)initWithDescriptor:(PYMIDIEndpointDescriptor*)descriptor;

/* Method for PYMIDIManager to call when the setup changes, abstract */
- (void)syncWithMIDIEndpoint;

- (BOOL)ioIsRunning;


@end
