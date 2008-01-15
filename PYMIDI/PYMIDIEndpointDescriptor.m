#import <PYMIDI/PYMIDIEndpointDescriptor.h>


@implementation PYMIDIEndpointDescriptor


+ (id)descriptorWithName:(NSString*)newName uniqueID:(SInt32)newUniqueID;
{
    return [[[PYMIDIEndpointDescriptor alloc] initWithName:newName uniqueID:newUniqueID] autorelease];
}


- (id)initWithName:(NSString*)newName uniqueID:(SInt32)newUniqueID
{
    self = [super init];
    
    name = [newName retain];
    uniqueID = newUniqueID;
    
    return self;
}


- (void)dealloc
{
    [name release];
    
    [super dealloc];
}


- (id)initWithCoder:(NSCoder*)coder
{
    self = [super init];
    
    name = [[coder decodeObjectForKey:@"name"] retain];
    uniqueID = [coder decodeInt32ForKey:@"uniqueID"];
    
    return self;
}

    
- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:name forKey:@"name"];
    [coder encodeInt32:uniqueID forKey:@"uniqueID"];
}


- (NSString*)name
{
    return name;
}


- (SInt32)uniqueID
{
    return uniqueID;
}


@end
