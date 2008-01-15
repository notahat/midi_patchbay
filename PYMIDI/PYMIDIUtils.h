/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: PYMIDIUtils.h,v 1.7 2004/01/12 04:40:38 pete Exp $
*/


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