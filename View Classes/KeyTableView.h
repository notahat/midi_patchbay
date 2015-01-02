#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

@interface KeyTableView : NSTableView  {

}

- (void)keyDown:(NSEvent *)theEvent;
- (void)deleteForward:(id)sender;
- (void)deleteBackward:(id)sender;
- (void)moveUp:(id)sender;
- (void)moveDown:(id)sender;

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>) menuItem;
- (void)clear:(id)sender;

- (void)textDidEndEditing:(NSNotification*)notification;

@end
