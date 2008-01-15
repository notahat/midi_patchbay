/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: PYMIDIVirtualSource.m,v 1.6 2004/01/10 13:58:31 pete Exp $
*/


#import <PYMIDI/PYMIDIVirtualSource.h>

#import <PYMIDI/PYMIDIUtils.h>
#import <PYMIDI/PYMIDIManager.h>


@implementation PYMIDIVirtualSource


- (id)initWithName:(NSString*)newName
{
    PYMIDIManager*		manager = [PYMIDIManager sharedInstance];
    MIDIEndpointRef		newEndpoint;
    OSStatus			error;
    SInt32				newUniqueID;
    
    // This makes sure that we don't get notified about this endpoint until after
    // we're done creating it.
    [manager disableNotifications];
    
    MIDISourceCreate ([manager midiClientRef], (CFStringRef)newName, &newEndpoint);
    
    // This code works around a bug in OS X 10.1 that causes
    // new sources/destinations to be created without unique IDs.
    error = MIDIObjectGetIntegerProperty (newEndpoint, kMIDIPropertyUniqueID, &newUniqueID);
    if (error == kMIDIUnknownProperty) {
        newUniqueID = PYMIDIAllocateUniqueID();
        MIDIObjectSetIntegerProperty (newEndpoint, kMIDIPropertyUniqueID, newUniqueID);
    }
    
    MIDIObjectSetIntegerProperty (newEndpoint, CFSTR("PYMIDIOwnerPID"), [[NSProcessInfo processInfo] processIdentifier]);
    
    [manager enableNotifications];

    self = [super initWithMIDIEndpointRef:newEndpoint];
    
    ioIsRunning = NO;

    return self;
}


- (void)processMIDIPacketList:(const MIDIPacketList*)packetList sender:(id)sender
{
    if (ioIsRunning) MIDIReceived (midiEndpointRef, packetList);
}


@end
