#import <PYMIDI/PYMIDIUtils.h>


NSString*
PYMIDIGetEndpointName (MIDIEndpointRef midiEndpointRef)
{
    OSStatus result;

    // Get the device name
    CFStringRef deviceName = nil;

    MIDIEntityRef entityRef;
    result = MIDIEndpointGetEntity (midiEndpointRef, &entityRef);
    if (result == noErr) {    
        MIDIDeviceRef deviceRef;
        result = MIDIEntityGetDevice (entityRef, &deviceRef);
        
        if (result == noErr) {
            result = MIDIObjectGetStringProperty (deviceRef, kMIDIPropertyName, &deviceName);
        }
    }

    // Get the endpoint name
    CFStringRef endpointName = nil;
	result =  MIDIObjectGetStringProperty (midiEndpointRef, kMIDIPropertyName, &endpointName);


    // Stick the two names together, handling all the cases where one or the other doesn't exist
    NSString* name;
    
    if (endpointName != nil) {
        if (deviceName != nil) {
            bool endpointNameBeginsWithDeviceName = 
                CFStringCompareWithOptions (
                    endpointName, deviceName,
                    CFRangeMake(0, CFStringGetLength (deviceName)),
                    kCFCompareCaseInsensitive
                ) == kCFCompareEqualTo;
                
            if (endpointNameBeginsWithDeviceName)
                name = [NSString stringWithString:(NSString*)endpointName];
            else
                name = [NSString stringWithFormat:@"%@ %@", deviceName, endpointName];
        }
        else
            name = [NSString stringWithString:(NSString*)endpointName];
    }
    
    else {
        if (deviceName != nil)
            name = [NSString stringWithString:(NSString*)deviceName];
        else
            name = nil;   // Hopefully we'll never get here!
    }

    
    // Clean up
    if (deviceName != nil) CFRelease (deviceName);
    if (endpointName != nil) CFRelease (endpointName);
    
    return name;
}


Boolean
PYMIDIDoesSourceStillExist (MIDIEndpointRef endpointToMatch)
{
    ItemCount count = MIDIGetNumberOfSources();
    ItemCount i;
    for (i = 0; i < count; i++) {
        MIDIEndpointRef endpoint = MIDIGetSource (i);
        
        if (endpoint == endpointToMatch)
            return YES;
    }
    
    return NO;
}


MIDIEndpointRef
PYMIDIGetSourceByUniqueID (SInt32 uniqueIDToMatch)
{
    ItemCount count, i;
    MIDIEndpointRef endpoint;
    OSStatus error;
    SInt32 uniqueID;
    
    count = MIDIGetNumberOfSources();
    for (i = 0; i < count; i++) {
        endpoint = MIDIGetSource (i);
        
        error = MIDIObjectGetIntegerProperty (endpoint, kMIDIPropertyUniqueID, &uniqueID);
        if (error == noErr && uniqueID == uniqueIDToMatch)
            return endpoint;
    }
    
    return NULL;
}



MIDIEndpointRef
PYMIDIGetSourceByName (NSString* nameToMatch)
{
    ItemCount count = MIDIGetNumberOfSources();
    ItemCount i;
    for (i = 0; i < count; i++) {
        MIDIEndpointRef endpoint = MIDIGetSource (i);
        
        NSString* name = PYMIDIGetEndpointName (endpoint);

        if (name != nil && [name isEqualToString:nameToMatch]) return endpoint;
    }
    
    return NULL;
}


Boolean
PYMIDIDoesDestinationStillExist (MIDIEndpointRef endpointToMatch)
{
    ItemCount count = MIDIGetNumberOfDestinations();
    ItemCount i;
    for (i = 0; i < count; i++) {
        MIDIEndpointRef endpoint = MIDIGetDestination (i);
        
        if (endpoint == endpointToMatch)
            return YES;
    }
    
    return NO;
}



MIDIEndpointRef
PYMIDIGetDestinationByUniqueID (SInt32 uniqueIDToMatch)
{
    ItemCount count, i;
    MIDIEndpointRef endpoint;
    OSStatus error;
    SInt32 uniqueID;
    
    count = MIDIGetNumberOfDestinations();
    for (i = 0; i < count; i++) {
        endpoint = MIDIGetDestination (i);
        
        error = MIDIObjectGetIntegerProperty (endpoint, kMIDIPropertyUniqueID, &uniqueID);
        if (error == noErr && uniqueID == uniqueIDToMatch)
            return endpoint;
    }
    
    return NULL;
}


MIDIEndpointRef
PYMIDIGetDestinationByName (NSString* nameToMatch)
{
    ItemCount count = MIDIGetNumberOfDestinations();
    ItemCount i;
    for (i = 0; i < count; i++) {
        MIDIEndpointRef endpoint = MIDIGetDestination (i);
        
        NSString* name = PYMIDIGetEndpointName (endpoint);

        if (name != nil && [name isEqualToString:nameToMatch]) return endpoint;
    }
    
    return NULL;
}
    
    
Boolean
PYMIDIIsUniqueIDInUse (SInt32 uniqueID)
{
    int count;
    int index;
    MIDIEndpointRef endpoint;
    SInt32 usedID;
    
    count = MIDIGetNumberOfSources();
    for (index = 0; index < count; index++) {
        endpoint = MIDIGetSource (index);
        MIDIObjectGetIntegerProperty (endpoint, kMIDIPropertyUniqueID, &usedID);
        if (usedID == uniqueID) return true;
    }
    
    count = MIDIGetNumberOfDestinations();
    for (index = 0; index < count; index++) {
        endpoint = MIDIGetDestination (index);
        MIDIObjectGetIntegerProperty (endpoint, kMIDIPropertyUniqueID, &usedID);
        if (usedID == uniqueID) return true;
    }
    
    return false;
}


SInt32
PYMIDIAllocateUniqueID (void)
{
    SInt32 uniqueID;
    static SInt32 sequence = 0;
    
    do {
        uniqueID = time (NULL) + sequence++;
    } while (PYMIDIIsUniqueIDInUse (uniqueID));
    
    return uniqueID;
}


Boolean
PYMIDIIsEndpointNameTaken (NSString* name)
{
    return PYMIDIGetSourceByName      (name) != NULL ||
           PYMIDIGetDestinationByName (name) != NULL;
}


Boolean
PYMIDIIsEndpointLocalVirtual (MIDIEndpointRef midiEndpointRef)
{
    SInt32 pid;
    OSStatus error = MIDIObjectGetIntegerProperty (midiEndpointRef, CFSTR("PYMIDIOwnerPID"), &pid);
    return error == noErr && pid == [[NSProcessInfo processInfo] processIdentifier];
}



@implementation NSArray(PYMIDIUtils)


- (NSArray*)filteredArrayUsingSelector:(SEL)filter
{
    NSMutableArray* newArray = [NSMutableArray array];
    
    BOOL (*method)(id, SEL);
    
    NSEnumerator* enumerator = [self objectEnumerator];
    id object;
    while (object = [enumerator nextObject]) {
        method = (BOOL (*)(id, SEL))[object methodForSelector:filter];
        if (method (object, filter))
        	[newArray addObject:object];
    }
    
    return [NSArray arrayWithArray:newArray];
}

@end 
