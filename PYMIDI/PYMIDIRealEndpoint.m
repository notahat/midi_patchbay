#import <PYMIDI/PYMIDIRealEndpoint.h>
#import <PYMIDI/PYMIDIEndpointDescriptor.h>


@implementation PYMIDIRealEndpoint


- (id)initWithMIDIEndpointRef:(MIDIEndpointRef)newMIDIEndpointRef
{
    self = [super initWithMIDIEndpointRef:newMIDIEndpointRef];
    
    if (self != nil) {
        midiPortRef = nil;
    }

    return self;
}


- (id)initWithDescriptor:(PYMIDIEndpointDescriptor*)descriptor
{
    self = [super initWithName:[descriptor name] uniqueID:[descriptor uniqueID]];
    
    if (self != nil) {
        midiPortRef = nil;
    }
    
    return self;
}


- (void)syncWithMIDIEndpoint
{
}


- (BOOL)ioIsRunning
{
    return midiPortRef != nil;
}


@end
