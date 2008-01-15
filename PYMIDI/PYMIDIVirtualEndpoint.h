/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: PYMIDIVirtualEndpoint.h,v 1.6 2004/01/10 13:58:32 pete Exp $
*/


#import <PYMIDI/PYMIDIEndpoint.h>


@interface PYMIDIVirtualEndpoint : PYMIDIEndpoint {
    BOOL ioIsRunning;
}

- (id)initWithName:(NSString*)newName;
- (void)dealloc;

- (id)initWithCoder:(NSCoder*)coder;

- (BOOL)isPrivate;
- (void)makePrivate:(BOOL)isPrivate;

- (BOOL)ioIsRunning;
- (void)startIO;
- (void)stopIO;

@end
