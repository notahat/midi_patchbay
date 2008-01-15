/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: PatchTableCell.m,v 1.2.2.2 2004/01/09 22:50:15 pete Exp $
*/


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
    [leftAlign setAlignment:NSLeftTextAlignment];
    [leftAlign setLineBreakMode:NSLineBreakByTruncatingTail];
    
    rightAlign = [[NSMutableParagraphStyle alloc] init];
    [rightAlign setAlignment:NSRightTextAlignment];
    [rightAlign setLineBreakMode:NSLineBreakByTruncatingTail];
    
    centerAlign = [[NSMutableParagraphStyle alloc] init];
    [centerAlign setAlignment:NSCenterTextAlignment];
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
