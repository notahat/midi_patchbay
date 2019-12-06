#import "KeyTableView.h"
#import "TableDataSource.h"

@implementation KeyTableView


- (void)keyDown:(NSEvent *)theEvent
{
    [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}


- (void)deleteForward:(id)sender
{
    [self clear:self];
}


- (void)deleteBackward:(id)sender
{
    [self clear:self];
}


// remove focus from table view on Esc so Ok button can respond to Enter
- (void)cancelOperation:(id)sender {
	[[self window] makeFirstResponder:self.window.contentView];
}


- (void)moveUp:(id)sender
{
    if ([self selectedRow] > 0) {
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:[self selectedRow] - 1] byExtendingSelection:NO];
    }
}


- (void)moveDown:(id)sender
{
    if ([self selectedRow] != -1 && [self selectedRow] < [self numberOfRows]-1) {
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:[self selectedRow] + 1] byExtendingSelection:NO];
    }
}


- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>) menuItem
{
    if ([menuItem action] == @selector(clear:))
        return [self numberOfSelectedRows] > 0;
        
    else
        return YES;
}


- (void)clear:(id)sender
{
    if ([self selectedRow] == -1) return;
	if ([[self dataSource] isKindOfClass:[TableDataSource class]]) {
		[(TableDataSource *)[self dataSource] deleteSelection:self];
        [self deselectAll:self];
		[self reloadData];
    }
}


// UPDATE: this isn't needed anymore in 10.10+ as the current selection appears to no longer change
//- (void)textDidEndEditing:(NSNotification*)notification
//{
//    // This is a hack to make the return key end editing and leave the selection
//    // on the current row rather than begin editing the next row.  It works by
//    // substituting a dodgy key code in place of the return key.
//
//    if ([[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement) {
//        NSMutableDictionary *newUserInfo =
//            [NSMutableDictionary dictionaryWithDictionary:[notification userInfo]];
//        [newUserInfo setObject:[NSNumber numberWithInt:NSIllegalTextMovement] forKey:@"NSTextMovement"];
//
//        NSNotification *newNotification = [NSNotification
//            notificationWithName:[notification name]
//            object:[notification object]
//            userInfo:newUserInfo
//        ];
//
//        [super textDidEndEditing:newNotification];
//
//        [[self window] makeFirstResponder:self];
//    }
//    else
//        [super textDidEndEditing:notification];
//}


@end
