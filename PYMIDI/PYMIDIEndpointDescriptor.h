/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: PYMIDIEndpointDescriptor.h,v 1.4 2004/01/10 14:00:03 pete Exp $
*/


#import <Foundation/Foundation.h>


@interface PYMIDIEndpointDescriptor : NSObject <NSCoding> {
    NSString*		name;
    SInt32			uniqueID;
}

+ (id)descriptorWithName:(NSString*)newName uniqueID:(SInt32)newUniqueID;

- (id)initWithName:(NSString*)newName uniqueID:(SInt32)newUniqueID;

- (void)dealloc;

- (id)initWithCoder:(NSCoder*)coder;
- (void)encodeWithCoder:(NSCoder*)coder;

- (NSString*)name;
- (SInt32)uniqueID;

@end
