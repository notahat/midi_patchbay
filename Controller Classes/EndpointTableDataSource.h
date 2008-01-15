/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: EndpointTableDataSource.h,v 1.4.2.3 2004/01/25 10:10:48 pete Exp $
*/


#import <Cocoa/Cocoa.h>

#import <PYMIDI/PYMIDI.h>


@interface EndpointTableDataSource : NSObject {
    Class			endpointClass;
    NSMutableArray*	endpointArray;
    NSUndoManager*  undoManager;
}

- (EndpointTableDataSource*)initWithEndpointClass:(Class)newEndpointClass endpointArray:(NSMutableArray*)newEndpointArray undoManager:(NSUndoManager*)newUndoManager;
- (void)dealloc;

- (void)setEndpointArray:(NSMutableArray*)newEndpointArray;

- (int)numberOfRowsInTableView:(NSTableView*)tableView;
- (id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)column row:(int)rowIndex;
- (BOOL)control:(NSControl*)control isValidObject:(id)value;
- (void)tableView:(NSTableView*)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn*)column row:(int)rowIndex;
- (void)deleteSelection:(NSTableView*)tableView;

- (BOOL)tabView:(NSTabView*)tabView shouldSelectTabViewItem:(NSTabViewItem*)tabViewItem;

- (void)tableView:(NSTableView*)tableView newEndpointWithName:(NSString*)name;
- (void)tableView:(NSTableView*)tableView addEndpoint:(PYMIDIVirtualEndpoint*)endpoint atIndex:(int)index;
- (void)tableView:(NSTableView*)tableView removeEndpointAtIndex:(int)index;
- (void)tableView:(NSTableView*)tableView setName:(NSString*)name forEndpointAtIndex:(int)index;

@end
