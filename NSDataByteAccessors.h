#import <Cocoa/Cocoa.h>

@interface NSData (ByteAccessors)
- (int)getByte:(int)offset;
@end

@interface NSMutableData (ByteAccessors)
- (void)setByteAt:(int)offset to:(int)value;
@end
