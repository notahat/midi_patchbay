#import <PYMIDI/PYMIDIEndpointSet.h>
#import <PYMIDI/PYMIDIEndpointDescriptor.h>
#import <PYMIDI/PYMIDIEndpoint.h>


@implementation PYMIDIEndpointSet


+ (id)endpointSetWithArray:(NSArray*)newEndpointArray
{
    return [[[PYMIDIEndpointSet alloc] initWithEndpointArray:newEndpointArray] retain];
}


- (id)initWithEndpointArray:(NSArray*)newEndpointArray
{
    self = [super init];
    
    if (self != nil) {
        endpointArray = [newEndpointArray retain];
    }
    
    return self;
}


- (void)dealloc
{
    [endpointArray release];
    
    [super dealloc];
}


- (id)archiver:(NSKeyedArchiver*)archiver willEncodeObject:(id)object
{
    if ([endpointArray containsObject:object])
        object = [object descriptor];
    
    return object;
}


- (id)unarchiver:(NSKeyedUnarchiver*)unarchiver didDecodeObject:(id)object
{
    if ([object isMemberOfClass:[PYMIDIEndpointDescriptor class]])
        object = [[self endpointWithDescriptor:object] retain];
        
    // Note that we DON'T need to release the original object when doing a
    // subsitution.  This is the opposite of what happens when we do it in
    // awakeAfterUsingCoder: in the object itself.
    
    return object;
}


- (PYMIDIEndpoint*)endpointWithDescriptor:(PYMIDIEndpointDescriptor*)descriptor
{
    PYMIDIEndpoint* endpoint;
    NSEnumerator* enumerator;
    
    // First try to match by unique ID...
    enumerator = [endpointArray objectEnumerator];
    while (endpoint = [enumerator nextObject]) {
        if ([endpoint uniqueID] == [descriptor uniqueID]) return endpoint;
    }
    
    // ...and, if that fails, try to match by name
    enumerator = [endpointArray objectEnumerator];
    while (endpoint = [enumerator nextObject]) {
        if ([[endpoint name] isEqualToString:[descriptor name]]) return endpoint;
    }
    
    return nil;
}


@end
