#import "PatchTableCell.h"
#import "PatchTableCellData.h"


@implementation PatchTableCell


- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    PatchTableCellData* data = [self objectValue];

    NSFont*						systemFont;
    NSFont*						smallSystemFont;
    NSMutableParagraphStyle*	leftAlign;
    NSMutableParagraphStyle*	rightAlign;
    NSMutableParagraphStyle*	centerAlign;
    
    NSRect						inputNameFrame;
    NSDictionary*				inputNameAttributes;
    NSRect						outputNameFrame;
    NSDictionary*				outputNameAttributes;
    NSPoint						arrowCenter;
    NSBezierPath*				arrow;
    NSRect						descriptionFrame;
    NSDictionary*				descriptionAttributes;
    
    systemFont = [NSFont systemFontOfSize:[NSFont systemFontSize]];
    smallSystemFont = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
    leftAlign = [[NSMutableParagraphStyle alloc] init];
    [leftAlign setAlignment:NSTextAlignmentLeft];
    [leftAlign setLineBreakMode:NSLineBreakByTruncatingTail];
    
    rightAlign = [[NSMutableParagraphStyle alloc] init];
    [rightAlign setAlignment:NSTextAlignmentRight];
    [rightAlign setLineBreakMode:NSLineBreakByTruncatingTail];
    
    centerAlign = [[NSMutableParagraphStyle alloc] init];
    [centerAlign setAlignment:NSTextAlignmentCenter];
    [centerAlign setLineBreakMode:NSLineBreakByTruncatingTail];
    
    
    inputNameFrame = NSMakeRect (
        cellFrame.origin.x + 10, cellFrame.origin.y,
        cellFrame.size.width / 2 - 30, 20
    );
    
    inputNameAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
        systemFont,			NSFontAttributeName,
        leftAlign,			NSParagraphStyleAttributeName,
        nil
    ];
    
    [[data inputName] drawInRect:inputNameFrame withAttributes:inputNameAttributes];
    
    
    outputNameFrame = NSMakeRect (
        cellFrame.origin.x + cellFrame.size.width / 2 + 20, cellFrame.origin.y,
        cellFrame.size.width / 2 - 30, 20
    );

    outputNameAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
        systemFont,			NSFontAttributeName,
        rightAlign,			NSParagraphStyleAttributeName,
        nil
    ];

    [[data outputName] drawInRect:outputNameFrame withAttributes:outputNameAttributes];
    
    
    arrowCenter = NSMakePoint (cellFrame.origin.x + cellFrame.size.width / 2, cellFrame.origin.y + 10);
    arrow = [NSBezierPath bezierPath];
    [arrow moveToPoint:NSMakePoint (arrowCenter.x - 15, arrowCenter.y + 1)];
    [arrow lineToPoint:NSMakePoint (arrowCenter.x, arrowCenter.y + 1)];
    [arrow lineToPoint:NSMakePoint (arrowCenter.x, arrowCenter.y + 5)];
    [arrow lineToPoint:NSMakePoint (arrowCenter.x + 15, arrowCenter.y)];
    [arrow lineToPoint:NSMakePoint (arrowCenter.x, arrowCenter.y - 5)];
    [arrow lineToPoint:NSMakePoint (arrowCenter.x, arrowCenter.y - 1)];
    [arrow lineToPoint:NSMakePoint (arrowCenter.x - 15, arrowCenter.y - 1)];
    [arrow closePath];
    [[NSColor blackColor] set];
    [arrow fill];
    
    
    descriptionFrame = NSMakeRect (
        cellFrame.origin.x, cellFrame.origin.y + 20,
        cellFrame.size.width, cellFrame.size.height - 20
    );
    
    descriptionAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
        smallSystemFont,	NSFontAttributeName,
        centerAlign,		NSParagraphStyleAttributeName,
        nil
    ];

    [[data description] drawInRect:descriptionFrame withAttributes:descriptionAttributes];
}


@end
