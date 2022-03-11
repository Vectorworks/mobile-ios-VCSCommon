#import <Foundation/Foundation.h>


typedef enum
{
    projectionOrthogonal		= 0,
    projectionPerspective 		= 1,
    projectionCavalierOblique45	= 2,
    projectionCavalierOblique30	= 3,
    projectionCabinetOblique45	= 4,
    projectionCabinetOblique30	= 5,
    projectionPlan				= 6
} Projection;

struct WorldRect
{
    double left;
    double right;
    double top;
    double bottom;
};
struct WorldPt
{
    double x;
    double y;
};

struct WorldPt3
{
    double x;
    double y;
    double z;
    
};

@interface CameraData : NSObject
{
@public
    struct WorldPt3 eyeVector;
    struct WorldPt3 upVector;
    struct WorldPt3 centerVector;
    
    struct WorldPt centerPt;
    struct WorldRect latBounds;
}

@property (assign)      Projection projection;
@property (assign)      double zoom;
@property (assign)      double scale;
@property (assign)      double fieldOfView;

@end
