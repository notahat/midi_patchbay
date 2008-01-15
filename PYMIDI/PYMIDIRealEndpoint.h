/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: PYMIDIRealEndpoint.h,v 1.4 2004/01/10 14:00:25 pete Exp $
*/


#import <PYMIDI/PYMIDIEndpoint.h>

@class PYMIDIEndpointDescriptor;


@interface PYMIDIRealEndpoint : PYMIDIEndpoint {
    MIDIPortRef		midiPortRef;
}

/* These should only be called by PYMIDIManager */
- (id)initWithMIDIEndpointRef:(MIDIEndpointRef)newMIDIEndpointRef;
- (id)initWithDescriptor:(PYMIDIEndpointDescriptor*)descriptor;

/* Method for PYMIDIManager to call when the setup changes, abstract */
- (void)syncWithMIDIEndpoint;

- (BOOL)ioIsRunning;


@end
