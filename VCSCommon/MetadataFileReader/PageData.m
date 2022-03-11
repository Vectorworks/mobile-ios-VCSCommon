#import "PageData.h"

@implementation PageData


@end

@implementation Viewport
-(id)init
{
    if ((self = [super init]))
    {
#if TARGET_OS_IPHONE
        self.viewportOutOfRegionTouches = [NSMutableSet setWithCapacity:5];
#endif
    }
    
    return self;
}

@end

@implementation CropOval


@end

@implementation CropPoly


@end

@implementation CropRect


@end

@implementation VWPoint


@end
