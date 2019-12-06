#import <Cocoa/Cocoa.h>
#import "TableDataSource.h"

@class Patch;
@class PatchbayDocument;


@interface PatchTableDataSource : TableDataSource  {
    PatchbayDocument*	document;
    NSMutableArray*		patchArray;
}

- (PatchTableDataSource*)initWithDocument:(PatchbayDocument*)newDocument patchArray:(NSMutableArray*)newPatchArray;

- (void)setPatchArray:(NSMutableArray*)newPatchArray;

- (int)numberOfRowsInTableView:(NSTableView*)tableView;
- (id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)column row:(int)rowIndex;
- (void)tableView:(NSTableView*)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn*)column row:(int)rowIndex;

@end
