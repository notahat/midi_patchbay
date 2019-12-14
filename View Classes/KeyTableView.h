#import <Cocoa/Cocoa.h>


@interface KeyTableView : NSTableView {

}

- (void)keyDown:(NSEvent *)theEvent;
- (void)deleteForward:(id)sender;
- (void)deleteBackward:(id)sender;
- (void)moveUp:(id)sender;
- (void)moveDown:(id)sender;

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item;
- (void)clear:(id)sender;

- (void)textDidEndEditing:(NSNotification*)notification;

@end
