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
