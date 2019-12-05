#import <Cocoa/Cocoa.h>

// simple base class to 
@interface TableDataSource : NSObject <NSTableViewDataSource, NSTableViewDelegate>

- (void)deleteSelection:(NSTableView*)tableView;

@end
