#import "RubyWrapper.h"
#import <MacRuby/MacRuby.h>

@implementation RubyWrapper

+ (id)sharedInstance {
    static RubyWrapper* instance = nil;
    if (instance == nil) instance = [[RubyWrapper alloc] init];
    return instance;
}

- (id)init {
    if (self = [super init]) {
	MacRuby* ruby = [MacRuby sharedRuntime];
	[ruby evaluateFileAtPath:[[NSBundle mainBundle] pathForResource:@"midi_filter" ofType:@"rb"]];
    }
    return self;
}

+ (id)evalString:(NSString*)string {
    [self sharedInstance];
    MacRuby* ruby = [MacRuby sharedRuntime];
    return [ruby evaluateString:string];
}

@end
