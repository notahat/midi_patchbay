/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: KeyTableView.h,v 1.3.2.2 2004/01/25 10:10:46 pete Exp $
*/


#import <Cocoa/Cocoa.h>


@interface KeyTableView : NSTableView {

}

- (void)keyDown:(NSEvent *)theEvent;
- (void)deleteForward:(id)sender;
- (void)deleteBackward:(id)sender;
- (void)moveUp:(id)sender;
- (void)moveDown:(id)sender;

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem;
- (void)clear:(id)sender;

- (void)textDidEndEditing:(NSNotification*)notification;

@end
