#import <Foundation/Foundation.h>

@class ClassData;

@interface VWFileMetadata : NSObject

// Array of PageData
@property (strong, nonatomic) NSArray *pages;

// Array of DesignLayerData
@property (strong, nonatomic) NSArray *designLayers;

// Array of SavedViewData
@property (strong, nonatomic) NSArray *savedViews;

// Array of RenderworksCameraData
@property (strong, nonatomic) NSArray *renderworksCameras;

// Array of Classes
@property (strong, nonatomic) NSArray<ClassData *> *classes;

- (id)initWithFile:(NSString*) filePath;

@end
