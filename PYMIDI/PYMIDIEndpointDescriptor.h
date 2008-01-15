#import <Foundation/Foundation.h>


@interface PYMIDIEndpointDescriptor : NSObject <NSCoding> {
    NSString*		name;
    SInt32			uniqueID;
}

+ (id)descriptorWithName:(NSString*)newName uniqueID:(SInt32)newUniqueID;

- (id)initWithName:(NSString*)newName uniqueID:(SInt32)newUniqueID;

- (void)dealloc;

- (id)initWithCoder:(NSCoder*)coder;
- (void)encodeWithCoder:(NSCoder*)coder;

- (NSString*)name;
- (SInt32)uniqueID;

@end
