/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: PYMIDIVirtualEndpoint.m,v 1.5 2004/01/10 13:58:32 pete Exp $
*/


#import <PYMIDI/PYMIDIVirtualEndpoint.h>

#import <PYMIDI/PYMIDIManager.h>


@implementation PYMIDIVirtualEndpoint


- (id)initWithName:(NSString*)newName
{
    return self;
}


- (void)dealloc
{
    PYMIDIManager* manager = [PYMIDIManager sharedInstance];
    
    [manager disableNotifications];
    MIDIEndpointDispose (midiEndpointRef);
    [manager enableNotifications];
    
    [super dealloc];
}


- (id)initWithCoder:(NSCoder*)coder
{
    NSString*		newName;
    SInt32			newUniqueID;
    
    self = [super initWithCoder:coder];

    newName     = [coder decodeObjectForKey:@"name"];
    newUniqueID = [coder decodeInt32ForKey:@"uniqueID"];
    
    self = [self initWithName:newName];
    [self setUniqueID:newUniqueID];
    
    return self;
}


- (BOOL)isPrivate
{
    OSStatus result;
    SInt32 isPrivate;
    
    result = MIDIObjectGetIntegerProperty (midiEndpointRef, kMIDIPropertyPrivate, &isPrivate);
    if (result == noErr)
        return isPrivate != 0;
    else
        return NO;
}


- (void)makePrivate:(BOOL)isPrivate
{
    MIDIObjectSetIntegerProperty (midiEndpointRef, kMIDIPropertyPrivate, isPrivate ? 1 : 0);
}


- (BOOL)ioIsRunning
{
    return ioIsRunning;
}


- (void)startIO
{
    ioIsRunning = YES;
}


- (void)stopIO
{
	ioIsRunning = NO;
}


@end
