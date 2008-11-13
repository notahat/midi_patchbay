#import <PYMIDI/PYMIDIVirtualEndpoint.h>
#import <PYMIDI/PYMIDIManager.h>

@implementation PYMIDIVirtualEndpoint


- (id)initWithName:(NSString*)newName {
    return self;
}


- (void)invalidate {
	PYMIDIManager* manager = [PYMIDIManager sharedInstance];
    [manager disableNotifications];
    if (midiEndpointRef != nil) MIDIEndpointDispose(midiEndpointRef);
	midiEndpointRef = nil;
    [manager enableNotifications];
}


- (void)dealloc {
	[self invalidate];
    [super dealloc];
}


- (void)finalize {
	[self invalidate];
	[super finalize];
}


- (id)initWithCoder:(NSCoder*)coder {
    NSString*		newName;
    SInt32			newUniqueID;
    
    self = [super initWithCoder:coder];

    newName     = [coder decodeObjectForKey:@"name"];
    newUniqueID = [coder decodeInt32ForKey:@"uniqueID"];
    
    self = [self initWithName:newName];
    [self setUniqueID:newUniqueID];
    
    return self;
}


- (BOOL)isPrivate {
	if (midiEndpointRef == nil) return NO;
	
    OSStatus result;
    SInt32 isPrivate;
    
	result = MIDIObjectGetIntegerProperty (midiEndpointRef, kMIDIPropertyPrivate, &isPrivate);
	if (result == noErr)
		return isPrivate != 0;
	else
		return NO;
}

- (void)makePrivate:(BOOL)isPrivate {
	if (midiEndpointRef == nil) return;
	MIDIObjectSetIntegerProperty (midiEndpointRef, kMIDIPropertyPrivate, isPrivate ? 1 : 0);
}


- (BOOL)ioIsRunning {
    return ioIsRunning;
}

- (void)startIO {
    ioIsRunning = YES;
}

- (void)stopIO {
	ioIsRunning = NO;
}


@end
