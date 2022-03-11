#import <Foundation/Foundation.h>

typedef enum
{
    VGMVisible = 0,
    VGMBlackAndWhite,
    VGMGrayed,
    VGMInvisible,
} VGMVisibility;

@interface DesignLayerData : NSObject

-(instancetype)initWithCStringName:(const char *)cStringName ID:(UInt32)ID andVisibility:(VGMVisibility)visibility;

@property (strong, nonatomic, readonly) NSString *name;
@property (readonly) UInt32 ID;
@property (assign) VGMVisibility visibility;

@end
