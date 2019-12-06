#import <Cocoa/Cocoa.h>

// simple base class for deletion selector
@interface TableDataSource : NSObject <NSTableViewDataSource, NSTableViewDelegate>

- (void)deleteSelection:(NSTableView*)tableView;

@end
