#import "NSDataByteAccessors.h"

@implementation NSData (ByteAccessors)

- (int)getByte:(int)offset {
    unsigned char* bytes = (unsigned char*)[self bytes];
    return bytes[offset];
}

@end


@implementation NSMutableData (ByteAccessors)

- (void)setByteAt:(int)offset to:(int)value {
    unsigned char* bytes = (unsigned char*)[self mutableBytes];
    bytes[offset] = value;
}

@end