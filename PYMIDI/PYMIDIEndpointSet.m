/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: PYMIDIEndpointSet.m,v 1.5 2004/01/11 13:26:30 pete Exp $
*/


#import <PYMIDI/PYMIDIEndpointSet.h>

#import <PYMIDI/PYMIDIEndpointDescriptor.h>
#import <PYMIDI/PYMIDIEndpoint.h>


@implementation PYMIDIEndpointSet


+ (id)endpointSetWithArray:(NSArray*)newEndpointArray
{
    return [[[PYMIDIEndpointSet alloc] initWithEndpointArray:newEndpointArray] retain];
}


- (id)initWithEndpointArray:(NSArray*)newEndpointArray
{
    self = [super init];
    
    if (self != nil) {
        endpointArray = [newEndpointArray retain];
    }
    
    return self;
}


- (void)dealloc
{
    [endpointArray release];
    
    [super dealloc];
}


- (id)archiver:(NSKeyedArchiver*)archiver willEncodeObject:(id)object
{
    if ([endpointArray containsObject:object])
        object = [object descriptor];
    
    return object;
}


- (id)unarchiver:(NSKeyedUnarchiver*)unarchiver didDecodeObject:(id)object
{
    if ([object isMemberOfClass:[PYMIDIEndpointDescriptor class]])
        object = [[self endpointWithDescriptor:object] retain];
        
    // Note that we DON'T need to release the original object when doing a
    // subsitution.  This is the opposite of what happens when we do it in
    // awakeAfterUsingCoder: in the object itself.
    
    return object;
}


- (PYMIDIEndpoint*)endpointWithDescriptor:(PYMIDIEndpointDescriptor*)descriptor
{
    PYMIDIEndpoint* endpoint;
    NSEnumerator* enumerator;
    
    // First try to match by unique ID...
    enumerator = [endpointArray objectEnumerator];
    while (endpoint = [enumerator nextObject]) {
        if ([endpoint uniqueID] == [descriptor uniqueID]) return endpoint;
    }
    
    // ...and, if that fails, try to match by name
    enumerator = [endpointArray objectEnumerator];
    while (endpoint = [enumerator nextObject]) {
        if ([[endpoint name] isEqualToString:[descriptor name]]) return endpoint;
    }
    
    return nil;
}


@end
