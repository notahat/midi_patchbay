/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: PYMIDIRealEndpoint.m,v 1.3 2004/01/10 14:00:25 pete Exp $
*/


#import <PYMIDI/PYMIDIRealEndpoint.h>

#import <PYMIDI/PYMIDIEndpointDescriptor.h>


@implementation PYMIDIRealEndpoint


- (id)initWithMIDIEndpointRef:(MIDIEndpointRef)newMIDIEndpointRef
{
    self = [super initWithMIDIEndpointRef:newMIDIEndpointRef];
    
    if (self != nil) {
        midiPortRef = nil;
    }

    return self;
}


- (id)initWithDescriptor:(PYMIDIEndpointDescriptor*)descriptor
{
    self = [super initWithName:[descriptor name] uniqueID:[descriptor uniqueID]];
    
    if (self != nil) {
        midiPortRef = nil;
    }
    
    return self;
}


- (void)syncWithMIDIEndpoint
{
}


- (BOOL)ioIsRunning
{
    return midiPortRef != nil;
}


@end
