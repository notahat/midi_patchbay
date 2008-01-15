/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: PatchTableDataSource.h,v 1.4.2.2 2004/01/25 10:10:48 pete Exp $
*/


#import <Cocoa/Cocoa.h>

@class Patch;

@class PatchbayDocument;


@interface PatchTableDataSource : NSObject {
    PatchbayDocument*	document;
    NSMutableArray*		patchArray;
}

- (PatchTableDataSource*)initWithDocument:(PatchbayDocument*)newDocument patchArray:(NSMutableArray*)newPatchArray;
- (void)dealloc;

- (void)setPatchArray:(NSMutableArray*)newPatchArray;

- (int)numberOfRowsInTableView:(NSTableView*)tableView;
- (id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)column row:(int)rowIndex;
- (void)tableView:(NSTableView*)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn*)column row:(int)rowIndex;
- (void)deleteSelection:(NSTableView*)tableView;

@end
