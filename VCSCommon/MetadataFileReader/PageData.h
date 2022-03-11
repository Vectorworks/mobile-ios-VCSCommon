#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@interface PageData : NSObject

@property NSString *name;
@property int dpi;

// Units data
@property int style;
@property double unitsPerInch;
@property NSString *unitMark;
@property int decDimPrecision;
@property int angleUnit;
@property int angleDimPrecision;
@property double areaPerSqInch;
@property NSString* areaUnitMark;
@property int areaDecPrecision;

@property NSArray* viewports;

@end

@interface VWPoint : NSObject

@property double x;
@property double y;

@end

@interface CropRect : NSObject

@property double x;
@property double y;
@property double width;
@property double height;

@end

@interface CropPoly : NSObject
// list of VWPoints
@property NSArray *vertices;
@end

@interface CropOval : NSObject

@property VWPoint *center;
@property VWPoint *radius;

@end


#if TARGET_OS_IPHONE

// Not from xml data
@interface MeasurementLayer : CAShapeLayer
@end

@interface UIView (VCSMeasurement)
-(CGPoint) convertViewPointToVWSheetPagePoint:(CGPoint)pt;
-(CGPoint) convertVWSheetPagePointViewPoint:(CGPoint)pt;
@end

#endif

@interface Viewport : NSObject

@property double x;
@property double y;
@property double rotation;
@property double scale;

#if TARGET_OS_IPHONE
// these are not from the xml data
@property UIBezierPath *viewportRegion;
@property MeasurementLayer *viewportLayer;
@property(strong, nonatomic) NSMutableSet *viewportOutOfRegionTouches;
#endif
// only one of these will be valid at a time
@property CropRect *cropRect;
@property CropPoly *cropPoly;
@property CropOval *cropOval;

@end

