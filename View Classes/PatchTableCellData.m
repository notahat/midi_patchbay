/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: PatchTableCellData.m,v 1.2.2.1 2004/01/09 13:53:37 pete Exp $
*/


#import "PatchTableCellData.h"


@implementation PatchTableCellData


+ (PatchTableCellData*)dataWithInputName:(NSString*)newInputName outputName:(NSString*)newOutputName description:(NSString*)newDescription
{
    PatchTableCellData* data = [[PatchTableCellData alloc]
    	initWithInputName:newInputName outputName:newOutputName description:newDescription
    ];
    return [data autorelease];
}


- (PatchTableCellData*)initWithInputName:(NSString*)newInputName outputName:(NSString*)newOutputName description:(NSString*)newDescription
{
    inputName	= [newInputName retain];
    outputName	= [newOutputName retain];
    description	= [newDescription retain];
    
    return self;
}


- (void)dealloc
{
    [inputName release];
    [outputName release];
    [description release];
    
    [super dealloc];
}


- (NSString*)inputName
{
    return inputName;
}

- (NSString*)outputName
{
    return outputName;
}

- (NSString*)description
{
    return description;
}


- (id)copyWithZone:(NSZone *)zone
{
    PatchTableCellData* copy = [[self class] allocWithZone:zone];
    [copy initWithInputName:inputName outputName:outputName description:description];
    
    return copy;
}


@end
