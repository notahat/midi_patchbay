#import <PYMIDI/PYMIDIEndpoint.h>


@interface PYMIDIVirtualEndpoint : PYMIDIEndpoint {
    BOOL ioIsRunning;
}

- (id)initWithName:(NSString*)newName;
- (void)dealloc;

- (id)initWithCoder:(NSCoder*)coder;

- (BOOL)isPrivate;
- (void)makePrivate:(BOOL)isPrivate;

- (BOOL)ioIsRunning;
- (void)startIO;
- (void)stopIO;

@end
