#import "PatchTableCellData.h"


@implementation PatchTableCellData


+ (PatchTableCellData*)dataWithInputName:(NSString*)newInputName outputName:(NSString*)newOutputName description:(NSString*)newDescription
{
    PatchTableCellData* data = [[PatchTableCellData alloc]
    	initWithInputName:newInputName outputName:newOutputName description:newDescription
    ];
	return data;
}


- (PatchTableCellData*)initWithInputName:(NSString*)newInputName outputName:(NSString*)newOutputName description:(NSString*)newDescription
{
	inputName	= newInputName;
	outputName	= newOutputName;
	description	= newDescription;
    
    return self;
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
	return [copy initWithInputName:inputName outputName:outputName description:description];
}


@end
