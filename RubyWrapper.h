#import <Cocoa/Cocoa.h>

@interface RubyWrapper : NSObject {
}

+ (id)sharedInstance;
+ (id)evalString:(NSString*)string;

@end
