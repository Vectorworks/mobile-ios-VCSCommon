#import "VWFileMetadata.h"
#import "PageData.h"
#import "DesignLayerData.h"
#import "SavedViewData.h"
#import "RenderworksCameraData.h"
#import "ClassData.h"
@import KissXML;

@interface VWFileMetadata()

@property (nonatomic, retain) NSString* filePath;

@end

@implementation VWFileMetadata

- (id)initWithFile:(NSString*) filePath
{
    self = [super init];
    if (self)
    {
        self.filePath = filePath;
        
        [self parse];
    }
    return self;
}

-(id) copyWithZone: (NSZone *) zone
{
    VWFileMetadata *copy = [[VWFileMetadata allocWithZone: zone] init];
    
    [copy setPages: self.pages];
    
    // Deep copy the design layers
    NSMutableArray* layers = [NSMutableArray new];
    for (DesignLayerData* layer in self.designLayers)
         [layers addObject:[layer copy]];
    [copy setDesignLayers: layers];
         
    [copy setSavedViews: self.savedViews];
    [copy setRenderworksCameras: self.renderworksCameras];
    [copy setClasses:self.classes];
    
    return copy;
}

-(void)parse
{
    DDXMLDocument *theDocument;
    
    NSError *error = nil;
    
    NSData* data  = [[NSFileManager defaultManager] contentsAtPath:self.filePath];
    NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // Document was UTF-8
    if (string != nil) {
        
        theDocument = [[DDXMLDocument alloc] initWithXMLString:string options:0 error:&error];
    }
    // If string is nil, that means the encoding was Unicode (UTF-16), not UTF-8
    else {
        
        NSString *unicodeDataString = [[NSString alloc] initWithData:data encoding:NSUnicodeStringEncoding];
        NSData *unicodeData = [unicodeDataString dataUsingEncoding:NSUnicodeStringEncoding];
        
        theDocument = [[DDXMLDocument alloc] initWithData:unicodeData options:0 error:&error];
    }
    
    if (theDocument == nil) {
        NSLog(@"Failed to initialize DDXMLDocument object!");
    }
    else {
        [self parseDesignLayers:theDocument];
        [self parseClasses:theDocument];
        [self parseSavedViews:theDocument];
        [self parseRenderworksCameras:theDocument];
        [self parsePages:theDocument];
    }
}

-(void) parseDesignLayers:(DDXMLDocument*) theDocument
{
    NSMutableArray* layers = [[NSMutableArray alloc] init];
    
    NSError *error = nil;
    NSArray *xmlLayerElements = [theDocument nodesForXPath:@"./data/DesignLayer" error:&error];
    
    for (DDXMLElement *layerElement in xmlLayerElements)
    {
        DesignLayerData* designLayer = [self parseDesignLayerElement:layerElement];
        [layers addObject:designLayer];
    }
    self.designLayers = layers;
}


-(void) parseClasses:(DDXMLDocument*) theDocument
{
    NSMutableArray* classes = [[NSMutableArray alloc] init];
    
    NSError *error = nil;
    NSArray *xmlClassElements = [theDocument nodesForXPath:@"./data/Class" error:&error];
    
    for (DDXMLElement *classElement in xmlClassElements)
    {
        ClassData* classData = [self parseClassElement:classElement];
        [classes addObject:classData];
    }
    self.classes = classes;
}

-(ClassData*) parseClassElement:(DDXMLElement*) classElement
{
    DDXMLElement *name = [self firstElementFor:@"Name" fromElement:classElement];
    // Pull out this element as a 64 bit long and cast to UInt32
    DDXMLElement *ID = [self firstElementFor:@"ID" fromElement:classElement];
    long long  layerId = [[ID stringValue] longLongValue];
    DDXMLElement *visibility = [self firstElementFor:@"Visibility" fromElement:classElement];
    ClassData* classData = [[ClassData alloc] initWithCStringName:name.stringValue.UTF8String ID:(UInt32)layerId andVisibility:[[visibility stringValue] intValue]];
    
    // this is just a patch and will need to be removed and fixed properly later, but for the time being we need to increment grayed and invisible visibilities by one because a new visibility type enum (black and white) was added in enum spot #1 and it's causing issues in VGM...  doing it here is the most seamless way for now
    switch (classData.visibility) {
        case 0:
            break;
        case 1:
        case 2:
            classData.visibility+=1;
            break;
        default:
            break;
    }
    
    return classData;
}

-(DesignLayerData*) parseDesignLayerElement:(DDXMLElement*) layerElement
{
    DDXMLElement *name = [self firstElementFor:@"Name" fromElement:layerElement];
    // Pull out this element as a 64 bit long and cast to UInt32
    DDXMLElement *ID = [self firstElementFor:@"ID" fromElement:layerElement];
    long long  layerId =[[ID stringValue] longLongValue];
    DDXMLElement *visibility = [self firstElementFor:@"Visibility" fromElement:layerElement];
    DesignLayerData* designLayer = [[DesignLayerData alloc] initWithCStringName:name.stringValue.UTF8String ID:(UInt32)layerId andVisibility:[[visibility stringValue] intValue]];
    
    // this is just a patch and will need to be removed and fixed properly later, but for the time being we need to increment grayed and invisible visibilities by one because a new visibility type enum (black and white) was added in enum spot #1 and it's causing issues in VGM...  doing it here is the most seamless way for now
    switch (designLayer.visibility) {
        case 0:
            break;
        case 1:
        case 2:
            designLayer.visibility+=1;
            break;
        default:
            break;
    }
    
    return designLayer;
}

-(void) parseSavedViews:(DDXMLDocument*) theDocument
{
    NSError *error = nil;
    
    // If no top level SavedViews element, nil represents that this data doesn't exist, empty list means it does exist but no saved views in file
    NSArray *xmlSavedViews = [theDocument nodesForXPath:@"./data/SavedViews" error:&error];
    if (xmlSavedViews.count == 0)
    {
        self.savedViews = nil;
    }
    else
    {
        NSMutableArray* savedViews = [[NSMutableArray alloc] init];
        
        NSArray *xmlSavedViewElements = [theDocument nodesForXPath:@"./data/SavedViews/SavedView" error:&error];
        
        for (DDXMLElement *savedViewElement in xmlSavedViewElements)
        {
            SavedViewData* savedView = [[SavedViewData alloc] init];
            
            DDXMLElement *name = [self firstElementFor:@"Name" fromElement:savedViewElement];
            savedView.name =  [name stringValue];
            
            NSMutableArray* designLayers = [NSMutableArray array];
            NSArray *xmlLayerElements = [savedViewElement elementsForName:@"DesignLayer"];
            for (DDXMLElement *layerElement in xmlLayerElements)
            {
                DesignLayerData* designLayer = [self parseDesignLayerElement:layerElement];
                [designLayers addObject:designLayer];
            }
            savedView.designLayers = designLayers;
            
            savedView.camera = [self parseCameraElement:[self firstElementFor:@"Camera" fromElement:savedViewElement]];
            
            [savedViews addObject:savedView];
        }
        self.savedViews = savedViews;
    }
}

-(void) parseRenderworksCameras:(DDXMLDocument*) theDocument
{
    NSError *error = nil;
    
    // If no top level RenderworksCameras element, nil represents that this data doesn't exist, empty list means it does exist but no saved views in file
    NSArray *xmlRenderworksCameras = [theDocument nodesForXPath:@"./data/RenderworksCameras" error:&error];
    if (xmlRenderworksCameras.count == 0)
    {
        self.renderworksCameras = nil;
    }
    else
    {
        NSMutableArray* renderworksCameras = [[NSMutableArray alloc] init];
        
        NSArray *xmlRenderworksCameraElements = [theDocument nodesForXPath:@"./data/RenderworksCameras/RenderworksCamera" error:&error];
        
        for (DDXMLElement *renderworksCameraElement in xmlRenderworksCameraElements)
        {
            RenderworksCameraData* renderworksCamera = [[RenderworksCameraData alloc] init];
            
            DDXMLElement *name = [self firstElementFor:@"Name" fromElement:renderworksCameraElement];
            renderworksCamera.name =  [name stringValue];
            
            renderworksCamera.camera = [self parseCameraElement:[self firstElementFor:@"Camera" fromElement:renderworksCameraElement]];
            
            [renderworksCameras addObject:renderworksCamera];
        }
        self.renderworksCameras = renderworksCameras;
    }
}

-(CameraData*) parseCameraElement:(DDXMLElement*) cameraElement
{
    CameraData* camera = nil;
    
    if (cameraElement)
    {
        camera = [[CameraData alloc] init];
        
        DDXMLElement *projectionElement = [self firstElementFor:@"Projection" fromElement:cameraElement];
        camera.projection =  [[projectionElement stringValue] intValue];
        
        DDXMLElement *zoomElement = [self firstElementFor:@"Zoom" fromElement:cameraElement];
        camera.zoom = [[zoomElement stringValue] doubleValue];
        
        DDXMLElement *scaleElement = [self firstElementFor:@"Scale" fromElement:cameraElement];
        camera.scale = [[scaleElement stringValue] doubleValue];
        
        DDXMLElement *fieldOfViewElement = [self firstElementFor:@"FieldOfView" fromElement:cameraElement];
        camera.fieldOfView = [[fieldOfViewElement stringValue] doubleValue];
        
        camera->eyeVector = [self parseWorldPt3:[self firstElementFor:@"CameraLocation" fromElement:cameraElement]];
        camera->upVector = [self parseWorldPt3:[self firstElementFor:@"UpVector" fromElement:cameraElement]];
        camera->centerVector = [self parseWorldPt3:[self firstElementFor:@"CenterVector" fromElement:cameraElement]];
        camera->centerPt = [self parseWorldPt:[self firstElementFor:@"CenterPt" fromElement:cameraElement]];
        camera->latBounds = [self parseWorldRect:[self firstElementFor:@"LatBounds" fromElement:cameraElement]];
        
    }
    return camera;
}

-(struct WorldRect) parseWorldRect:(DDXMLElement*) vec4Element
{
    struct WorldRect worldRect;
    NSString* vecString = [vec4Element stringValue];
    NSArray* parts = [vecString componentsSeparatedByString:@","];
    if (parts.count == 4)
    {
        worldRect.left = [parts[0] doubleValue];
        worldRect.right = [parts[1] doubleValue];
        worldRect.bottom = [parts[2] doubleValue];
        worldRect.top = [parts[3] doubleValue];
    }
    return worldRect;
}

-(struct WorldPt3) parseWorldPt3:(DDXMLElement*) vec3Element
{
    struct WorldPt3 worldPt3;
    NSString* vecString = [vec3Element stringValue];
    NSArray* parts = [vecString componentsSeparatedByString:@","];
    if (parts.count == 3)
    {
        worldPt3.x = [parts[0] doubleValue];
        worldPt3.y = [parts[1] doubleValue];
        worldPt3.z = [parts[2] doubleValue];
    }
    return worldPt3;
}

-(struct WorldPt) parseWorldPt:(DDXMLElement*) vecElement
{
    struct WorldPt worldPt;
    NSString* vecString = [vecElement stringValue];
    NSArray* parts = [vecString componentsSeparatedByString:@","];
    if (parts.count == 2)
    {
        worldPt.x = [parts[0] doubleValue];
        worldPt.y = [parts[1] doubleValue];
    }
    return worldPt;
}

-(void) parsePages:(DDXMLDocument*) theDocument
{
    NSMutableArray* pages = [[NSMutableArray alloc] init];
    
    NSError *error = nil;
    NSArray *xmlPageElements = [theDocument nodesForXPath:@"//data//Page" error:&error];
    
    for (DDXMLElement *pageElement in xmlPageElements)
    {
        PageData *pageData = [[PageData alloc] init];
        
        // todo get index
        
        DDXMLElement *name = [self firstElementFor:@"Name" fromElement:pageElement];
        pageData.name =  [name stringValue];
        
        DDXMLElement *dpi = [self firstElementFor:@"DPI" fromElement:pageElement];
        pageData.dpi = [[dpi stringValue] intValue];
        
        // Units
        DDXMLElement *units = [self firstElementFor:@"Units" fromElement:pageElement];
        DDXMLElement *style = [self firstElementFor:@"Style" fromElement:units];
        pageData.style = [[style stringValue] intValue];
        DDXMLElement *unitsPerInch = [self firstElementFor:@"UnitsPerInch" fromElement:units];
        pageData.unitsPerInch = [[unitsPerInch stringValue] doubleValue];
        DDXMLElement *unitMark = [self firstElementFor:@"UnitMark" fromElement:units];
        pageData.unitMark = [unitMark stringValue];
        DDXMLElement *decDimPrecision = [self firstElementFor:@"DecDimPrecission" fromElement:units];
        pageData.decDimPrecision = [[decDimPrecision stringValue] doubleValue];
        DDXMLElement *angUnit = [self firstElementFor:@"AngUnit" fromElement:units];
        pageData.angleUnit = [[angUnit stringValue] doubleValue];
        DDXMLElement *angDimPrecision = [self firstElementFor:@"AngDimPrecision" fromElement:units];
        pageData.angleDimPrecision = [[angDimPrecision stringValue] doubleValue];
        DDXMLElement *areaPerSqInch = [self firstElementFor:@"AreaPerSqInch" fromElement:units];
        pageData.areaPerSqInch = [[areaPerSqInch stringValue] doubleValue];
        DDXMLElement *areaUnitMark = [self firstElementFor:@"AreaUnitMark" fromElement:units];
        pageData.areaUnitMark = [areaUnitMark stringValue];
        DDXMLElement *areaDecPrecision = [self firstElementFor:@"AreaDecPrecision" fromElement:units];
        pageData.areaDecPrecision = [[areaDecPrecision stringValue] doubleValue];
        
        NSMutableArray *viewports = [[NSMutableArray alloc] init];
        
        // loop through Viewports
        NSArray *viewportElements = [pageElement elementsForName:@"Viewport"];
        for (DDXMLElement *viewportElement in viewportElements)
        {
            Viewport *viewport = [[Viewport alloc] init];
            
            DDXMLElement *info = [self firstElementFor:@"Info" fromElement:viewportElement];
            DDXMLElement *locX = [self firstElementFor:@"LocX" fromElement:info];
            viewport.x = [[locX stringValue] doubleValue];
            DDXMLElement *locY = [self firstElementFor:@"LocY" fromElement:info];
            viewport.y = [[locY stringValue] doubleValue];
            DDXMLElement *rotation = [self firstElementFor:@"Rotation" fromElement:info];
            viewport.rotation = [[rotation stringValue] doubleValue];
            DDXMLElement *scale = [self firstElementFor:@"Scale" fromElement:info];
            viewport.scale = [[scale stringValue] doubleValue];
            
            // Crops
            DDXMLElement *crop = [self firstElementFor:@"Crop" fromElement:viewportElement];
            if (crop)
            {
                DDXMLElement *cropRect = [self firstElementFor:@"Rect" fromElement:crop];
                if (cropRect)
                {
                    CropRect *crop = [[CropRect alloc] init];
                    DDXMLElement *x = [self firstElementFor:@"X" fromElement:cropRect];
                    crop.x = [[x stringValue] doubleValue];
                    DDXMLElement *y = [self firstElementFor:@"Y" fromElement:cropRect];
                    crop.y = [[y stringValue] doubleValue];
                    DDXMLElement *width =[self firstElementFor:@"Width" fromElement:cropRect];
                    crop.width = [[width stringValue] doubleValue];
                    DDXMLElement *height =[self firstElementFor:@"Height" fromElement:cropRect];
                    crop.height = [[height stringValue] doubleValue];
                    
                    viewport.cropRect = crop;
                }
                DDXMLElement *cropPoly = [self firstElementFor:@"Poly" fromElement:crop];
                if (cropPoly)
                {
                    CropPoly *crop = [[CropPoly alloc] init];
                    
                    NSMutableArray *vertices = [[NSMutableArray alloc] init];
                    NSArray *vertexElements = [cropPoly elementsForName:@"Vertex"];
                    for (DDXMLElement *vertex in vertexElements)
                    {
                        VWPoint *p = [[VWPoint alloc] init];
                        DDXMLElement *x = [self firstElementFor:@"x" fromElement:vertex];
                        p.x = [[x stringValue] doubleValue];
                        DDXMLElement *y = [self firstElementFor:@"y" fromElement:vertex];
                        p.y = [[y stringValue] doubleValue];
                        
                        [vertices addObject:p];
                    }
                    crop.vertices = vertices;
                    
                    viewport.cropPoly = crop;
                }
                
                DDXMLElement *cropOval = [self firstElementFor:@"Oval" fromElement:crop];
                if (cropOval)
                {
                    CropOval *crop = [[CropOval alloc] init];
                    
                    VWPoint *center = [[VWPoint alloc] init];
                    DDXMLElement *x = [self firstElementFor:@"CenterX" fromElement:cropOval];
                    center.x = [[x stringValue] doubleValue];
                    DDXMLElement *y = [self firstElementFor:@"CenterY" fromElement:cropOval];
                    center.y = [[y stringValue] doubleValue];
                    
                    crop.center = center;
                    
                    VWPoint *radius = [[VWPoint alloc] init];
                    DDXMLElement *rx = [self firstElementFor:@"RadiusX" fromElement:cropOval];
                    radius.x = [[rx stringValue] doubleValue];
                    DDXMLElement *ry = [self firstElementFor:@"RadiusY" fromElement:cropOval];
                    radius.y = [[ry stringValue] doubleValue];
                    
                    crop.radius = radius;
                    
                    viewport.cropOval = crop;
                }
                
                [viewports addObject:viewport];
            }
            
        }
        
        pageData.viewports = viewports;
        
        [pages addObject:pageData];
    }
    
    self.pages = pages;
}

-(DDXMLElement*)firstElementFor:(NSString*)elementName fromElement:(DDXMLElement*)parent
{
    NSArray *elements = [parent elementsForName:elementName];
    if (elements && elements.count > 0)
    {
        return elements[0];
    }
    return nil;
}

@end
