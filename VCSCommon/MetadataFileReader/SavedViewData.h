#import <Foundation/Foundation.h>
#import "CameraData.h"


@interface SavedViewData : NSObject

@property (strong, nonatomic)   NSString* name;

@property (strong, nonatomic)   NSArray* designLayers;

@property (strong, nonatomic)   CameraData* camera;

@end
