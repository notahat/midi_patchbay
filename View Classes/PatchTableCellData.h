#import <Foundation/Foundation.h>


@interface PatchTableCellData : NSObject <NSCopying> {
    NSString* inputName;
    NSString* outputName;
    NSString* description;
}

+ (PatchTableCellData*)dataWithInputName:(NSString*)newInputName outputName:(NSString*)newOutputName description:(NSString*)newDescription;

- (PatchTableCellData*)initWithInputName:(NSString*)newInputName outputName:(NSString*)newOutputName description:(NSString*)newDescription;

- (NSString*)inputName;
- (NSString*)outputName;
- (NSString*)description;

- (id)copyWithZone:(NSZone *)zone;

@end
