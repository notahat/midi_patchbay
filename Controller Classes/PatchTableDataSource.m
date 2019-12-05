#import "PatchTableDataSource.h"
#import "Patch.h"
#import "PatchTableCellData.h"
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
    return (int)[patchArray count];
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
    [document removePatchAtIndex:(int)[tableView selectedRow]];
}


@end
