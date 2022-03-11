#import "DesignLayerData.h"

@interface DesignLayerData ()

@property (assign) UInt32 ID;
@property (strong, nonatomic) NSString *name;

@end

@implementation DesignLayerData

-(instancetype)initWithCStringName:(const char *)cStringName ID:(UInt32)ID andVisibility:(VGMVisibility)visibility
{
    self = [super init];
    if (self)
    {
        self.name = [NSString stringWithCString:cStringName encoding:NSUTF8StringEncoding];
        self.ID = ID;
        self.visibility = visibility;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[DesignLayerData class]])
    {
        return self.ID == ((DesignLayerData*)object).ID;
    }
    else
    {
        return false;
    }
}

-(id) copyWithZone: (NSZone *) zone
{
    DesignLayerData *copy = [[DesignLayerData allocWithZone: zone] init];
    
    [copy setName:self.name];
    [copy setID: self.ID];
    [copy setVisibility:self.visibility];
    
    return copy;
}

@end
