/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: PatchTableCellData.h,v 1.2.2.2 2004/01/25 10:10:47 pete Exp $
*/


#import <Foundation/Foundation.h>


@interface PatchTableCellData : NSObject <NSCopying> {
    NSString* inputName;
    NSString* outputName;
    NSString* description;
}

+ (PatchTableCellData*)dataWithInputName:(NSString*)newInputName outputName:(NSString*)newOutputName description:(NSString*)newDescription;

- (PatchTableCellData*)initWithInputName:(NSString*)newInputName outputName:(NSString*)newOutputName description:(NSString*)newDescription;
- (void)dealloc;

- (NSString*)inputName;
- (NSString*)outputName;
- (NSString*)description;

- (id)copyWithZone:(NSZone *)zone;

@end
