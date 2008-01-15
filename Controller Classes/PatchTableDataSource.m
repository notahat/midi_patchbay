/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: PatchTableDataSource.m,v 1.5.2.1 2004/01/09 13:53:35 pete Exp $
*/


#import "PatchTableDataSource.h"

#import "Patch.h"

#import "PatchTableCellData.h";

#import "PatchbayDocument.h"


@implementation PatchTableDataSource


- (PatchTableDataSource*)initWithDocument:(PatchbayDocument*)newDocument patchArray:(NSMutableArray*)newPatchArray;
{
    self = [super init];
    
    if (self != nil) {
        document = newDocument;
        patchArray = [newPatchArray retain];
    }
    
    return self;
}


- (void)dealloc
{
    [patchArray release];
    
    [super dealloc];
}


- (void)setPatchArray:(NSMutableArray*)newPatchArray
{
    [newPatchArray retain];
    [patchArray release];
    patchArray = newPatchArray;
}


- (int)numberOfRowsInTableView:(NSTableView*)tableView
{
    return [patchArray count];
}


- (id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)column row:(int)rowIndex
{
    Patch* patch = [patchArray objectAtIndex:rowIndex];
    id result = nil;
    
    if ([[column identifier] isEqualToString:@"enabled"]) {
        result = [NSNumber numberWithBool:[patch isEnabled]];
    }
    
    else if ([[column identifier] isEqualToString:@"patch"]) {
        result = [PatchTableCellData
            dataWithInputName:[[patch input] displayName]
            outputName:[[patch output] displayName]
            description:[patch description]
        ];
    }
    
    else {
        [NSException
            raise:NSInvalidArgumentException
            format:@"Bad column identifier '%@' in PatchTableDataSource", [column identifier]
        ];
    }
    
    return result;
}


- (void)tableView:(NSTableView*)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn*)column row:(int)rowIndex
{
    if ([[column identifier] isEqualToString:@"enabled"]) {
        [document setIsEnabled:[value boolValue] forPatch:[patchArray objectAtIndex:rowIndex]];
    }
    
    else if ([[column identifier] isEqualToString:@"patch"]) {
        // Don't do anything...we can't set these values
    }
    
    else {
        [NSException
            raise:NSInvalidArgumentException
            format:@"Bad column identifier '%@' in PatchTableDataSource", [column identifier]
        ];
    }
}


- (void)deleteSelection:(NSTableView*)tableView
{
    [document removePatchAtIndex:[tableView selectedRow]];
}


@end
