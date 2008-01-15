/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: PYMIDIEndpointDescriptor.m,v 1.3 2004/01/10 14:00:03 pete Exp $
*/


#import <PYMIDI/PYMIDIEndpointDescriptor.h>


@implementation PYMIDIEndpointDescriptor


+ (id)descriptorWithName:(NSString*)newName uniqueID:(SInt32)newUniqueID;
{
    return [[[PYMIDIEndpointDescriptor alloc] initWithName:newName uniqueID:newUniqueID] autorelease];
}


- (id)initWithName:(NSString*)newName uniqueID:(SInt32)newUniqueID
{
    self = [super init];
    
    name = [newName retain];
    uniqueID = newUniqueID;
    
    return self;
}


- (void)dealloc
{
    [name release];
    
    [super dealloc];
}


- (id)initWithCoder:(NSCoder*)coder
{
    self = [super init];
    
    name = [[coder decodeObjectForKey:@"name"] retain];
    uniqueID = [coder decodeInt32ForKey:@"uniqueID"];
    
    return self;
}

    
- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:name forKey:@"name"];
    [coder encodeInt32:uniqueID forKey:@"uniqueID"];
}


- (NSString*)name
{
    return name;
}


- (SInt32)uniqueID
{
    return uniqueID;
}


@end
