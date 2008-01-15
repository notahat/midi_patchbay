#import <Foundation/Foundation.h>
#include <CoreMIDI/CoreMIDI.h>


NSString* PYMIDIGetEndpointName (MIDIEndpointRef endpoint);

Boolean PYMIDIDoesSourceStillExist (MIDIEndpointRef endpointToMatch);
MIDIEndpointRef PYMIDIGetSourceByUniqueID (SInt32 uniqueID);
MIDIEndpointRef PYMIDIGetSourceByName (NSString* name);

Boolean PYMIDIDoesDestinationStillExist (MIDIEndpointRef endpointToMatch);
MIDIEndpointRef PYMIDIGetDestinationByUniqueID (SInt32 uniqueID);
MIDIEndpointRef PYMIDIGetDestinationByName (NSString* name);

Boolean PYMIDIIsUniqueIDInUse (SInt32 uniqueID);
SInt32 PYMIDIAllocateUniqueID (void);
Boolean PYMIDIIsEndpointNameTaken (NSString* name);

Boolean PYMIDIIsEndpointLocalVirtual (MIDIEndpointRef endpoint);


@interface NSArray(PYMIDIUtils)

- (NSArray*)filteredArrayUsingSelector:(SEL)filter;

@end