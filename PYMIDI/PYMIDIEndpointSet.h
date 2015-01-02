#import <Foundation/Foundation.h>

@class PYMIDIEndpointDescriptor;
@class PYMIDIEndpoint;

@interface PYMIDIEndpointSet : NSObject <NSKeyedArchiverDelegate, NSKeyedUnarchiverDelegate> {
    NSArray*		endpointArray;
}


+ (id)endpointSetWithArray:(NSArray*)newEndpointArray;

- (id)initWithEndpointArray:(NSArray*)newEndpointArray;
- (void)dealloc;

- (id)archiver:(NSKeyedArchiver*)archiver willEncodeObject:(id)object;
- (id)unarchiver:(NSKeyedUnarchiver*)unarchiver didDecodeObject:(id)object;

- (PYMIDIEndpoint*)endpointWithDescriptor:(PYMIDIEndpointDescriptor*)descriptor;

@end
