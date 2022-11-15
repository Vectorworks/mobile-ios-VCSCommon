import Foundation
import KissXML
import CocoaLumberjackSwift
import simd

@objc public class VWFileMetadata: NSObject {
    @objc public var filePath: String
    @objc public var designLayers: [DesignLayerData] = []
    @objc public var classes: [ClassData] = []
    @objc public var savedViews: [SavedViewData] = []
    @objc public var renderworksCameras: [RenderworksCameraData] = []
    @objc public var pages: [PageData] = []
    
    
    @objc public init(withFile: String) {
        self.filePath = withFile
        super.init()
    }
    
    func parse() {
        guard let fileData = FileManager.default.contents(atPath: self.filePath), let theDocument = try? DDXMLDocument(data: fileData, options: 0) else {
            DDLogError("Failed to initialize DDXMLDocument object!")
            return
        }
        
        self.parseDesignLayers(theDocument)
        self.parseClasses(theDocument)
        self.parseSavedViews(theDocument)
        self.parseRenderworksCameras(theDocument)
        self.parsePages(theDocument)
    }
    
    func parseDesignLayers(_ fromDocument: DDXMLDocument) {
        self.designLayers.removeAll()
        guard let xmlLayerElements = try? fromDocument.nodes(forXPath: "./data/DesignLayer") else { return }
        
        xmlLayerElements.forEach {
            guard let xmlElement = $0 as? DDXMLElement, let designLayer = self.parseDesignLayerElement(layerElement: xmlElement) else { return }
            self.designLayers.append(designLayer)
        }
    }
    
    func parseDesignLayerElement(layerElement: DDXMLElement) -> DesignLayerData? {
        guard let name = self.firstElementFor(elementName: "Name", fromElement:layerElement)?.stringValue,
              let ID = UInt(self.firstElementFor(elementName: "ID", fromElement:layerElement)?.stringValue ?? ""),
              let visibility = Int(self.firstElementFor(elementName: "Visibility", fromElement:layerElement)?.stringValue ?? "")
        else { return nil }
        
        let designLayer = DesignLayerData()
        designLayer.ID = ID
        designLayer.name = name
        designLayer.visibility = visibility
        
        return designLayer
    }
    
    func parseClasses(_ fromDocument: DDXMLDocument) {
        self.classes.removeAll()
        guard let xmlLayerElements = try? fromDocument.nodes(forXPath: "./data/Class") else { return }
        
        xmlLayerElements.forEach {
            guard let xmlElement = $0 as? DDXMLElement, let classData = self.parseClassDataElement(layerElement: xmlElement) else { return }
            self.classes.append(classData)
        }
    }
    
    func parseClassDataElement(layerElement: DDXMLElement) -> ClassData? {
        guard let name = self.firstElementFor(elementName: "Name", fromElement:layerElement)?.stringValue,
              let ID = UInt(self.firstElementFor(elementName: "ID", fromElement:layerElement)?.stringValue ?? ""),
              let visibility = Int(self.firstElementFor(elementName: "Visibility", fromElement:layerElement)?.stringValue ?? "")
        else { return nil }
        
        let classData = ClassData()
        classData.ID = ID
        classData.name = name
        classData.visibility = visibility
        
        return classData
    }
    
    func parseSavedViews(_ fromDocument: DDXMLDocument) {
        self.savedViews.removeAll()
        guard let xmlSavedViewsElements = try? fromDocument.nodes(forXPath: "./data/SavedViews"), xmlSavedViewsElements.count > 0 else { return }
        guard let xmlSavedViewElements = try? fromDocument.nodes(forXPath: "./data/SavedViews/SavedView") else { return }
        
        xmlSavedViewElements.forEach {
            guard let xmlElement = $0 as? DDXMLElement else { return }
            let savedView = SavedViewData()
            savedView.name = self.firstElementFor(elementName: "Name", fromElement: xmlElement)?.stringValue ?? ""
            
            let xmlLayerElements = xmlElement.elements(forName: "DesignLayer")
            xmlLayerElements.forEach {
                guard let xmlElement = $0 as? DDXMLElement, let designLayer = self.parseDesignLayerElement(layerElement: xmlElement) else { return }
                savedView.designLayers.append(designLayer)
            }
            
            savedView.camera = self.parseCameraElement(self.firstElementFor(elementName: "Camera", fromElement: xmlElement))
            
            self.savedViews.append(savedView)
        }
    }
    
    func parseCameraElement(_ cameraElementOptional: DDXMLElement?) -> CameraData? {
        guard let cameraElement = cameraElementOptional else { return nil }
        let camera = CameraData()
        camera.projection = Int(self.firstElementFor(elementName: "Projection", fromElement: cameraElement)?.stringValue ?? "") ?? 0
        camera.zoom = Double(self.firstElementFor(elementName: "Zoom", fromElement: cameraElement)?.stringValue ?? "") ?? 0
        camera.scale = Double(self.firstElementFor(elementName: "Scale", fromElement: cameraElement)?.stringValue ?? "") ?? 0
        camera.fieldOfView = Double(self.firstElementFor(elementName: "FieldOfView", fromElement: cameraElement)?.stringValue ?? "") ?? 0
        
        camera.eyeVector = self.parseFloat3(self.firstElementFor(elementName: "CameraLocation", fromElement: cameraElement))
        camera.upVector = self.parseFloat3(self.firstElementFor(elementName: "UpVector", fromElement: cameraElement))
        camera.centerVector = self.parseFloat3(self.firstElementFor(elementName: "CenterVector", fromElement: cameraElement))
        camera.centerPt = self.parseFloat2(self.firstElementFor(elementName: "CenterVector", fromElement: cameraElement))
        camera.latBounds = self.parseCGRect(self.firstElementFor(elementName: "CenterVector", fromElement: cameraElement))
        
        return camera
    }
    
    func parseRenderworksCameras(_ fromDocument: DDXMLDocument) {
        self.renderworksCameras.removeAll()
        guard let xmlRenderworksCamerasElements = try? fromDocument.nodes(forXPath: "./data/RenderworksCameras"), xmlRenderworksCamerasElements.count > 0 else { return }
        guard let xmlRenderworksCameraElements = try? fromDocument.nodes(forXPath: "./data/SavedViews/RenderworksCamera") else { return }
        
        xmlRenderworksCameraElements.forEach {
            guard let xmlElement = $0 as? DDXMLElement else { return }
            let renderworksCameras = RenderworksCameraData()
            renderworksCameras.name = self.firstElementFor(elementName: "Name", fromElement: xmlElement)?.stringValue ?? ""
            renderworksCameras.camera = self.parseCameraElement(self.firstElementFor(elementName: "Camera", fromElement: xmlElement))
            
            self.renderworksCameras.append(renderworksCameras)
        }
    }
    
    func parsePages(_ fromDocument: DDXMLDocument) {
        self.pages.removeAll()
        guard let xmlPageElements = try? fromDocument.nodes(forXPath: "./data/Page") else { return }
        
        xmlPageElements.forEach {
            guard let xmlElement = $0 as? DDXMLElement else { return }
            let pageData = PageData()
            pageData.name = self.firstElementFor(elementName: "Name", fromElement: xmlElement)?.stringValue ?? ""
            pageData.dpi = Int(self.firstElementFor(elementName: "DPI", fromElement: xmlElement)?.stringValue ?? "") ?? 0
            
            if var units = self.firstElementFor(elementName: "Units", fromElement: xmlElement) {
                pageData.style = Int(self.firstElementFor(elementName: "Style", fromElement: units)?.stringValue ?? "") ?? 0
                pageData.unitsPerInch = Double(self.firstElementFor(elementName: "UnitsPerInch", fromElement: units)?.stringValue ?? "") ?? 0
                pageData.unitMark = self.firstElementFor(elementName: "UnitMark", fromElement: units)?.stringValue ?? ""
                pageData.decDimPrecision = Int(self.firstElementFor(elementName: "DecDimPrecission", fromElement: units)?.stringValue ?? "") ?? 0
                pageData.angleUnit = Int(self.firstElementFor(elementName: "AngUnit", fromElement: units)?.stringValue ?? "") ?? 0
                pageData.angleDimPrecision = Int(self.firstElementFor(elementName: "AngDimPrecision", fromElement: units)?.stringValue ?? "") ?? 0
                pageData.areaPerSqInch = Double(self.firstElementFor(elementName: "AreaPerSqInch", fromElement: units)?.stringValue ?? "") ?? 0
                pageData.areaUnitMark = self.firstElementFor(elementName: "AreaUnitMark", fromElement: units)?.stringValue ?? ""
                pageData.areaDecPrecision = Int(self.firstElementFor(elementName: "AreaDecPrecision", fromElement: units)?.stringValue ?? "") ?? 0
                
                xmlElement.elements(forName: "Viewport").forEach {
                    guard let viewportElement = $0 as? DDXMLElement else { return }
                    let viewport = Viewport()
                    
                    if var info = self.firstElementFor(elementName: "Info", fromElement: viewportElement) {
                        viewport.x = Double(self.firstElementFor(elementName: "LocX", fromElement: info)?.stringValue ?? "") ?? 0
                        viewport.y = Double(self.firstElementFor(elementName: "LocY", fromElement: info)?.stringValue ?? "") ?? 0
                        viewport.rotation = Double(self.firstElementFor(elementName: "Rotation", fromElement: info)?.stringValue ?? "") ?? 0
                        viewport.scale = Double(self.firstElementFor(elementName: "Scale", fromElement: info)?.stringValue ?? "") ?? 0
                    }
                    
                    if var crop = self.firstElementFor(elementName: "Crop", fromElement: viewportElement) {
                        if var cropRect = self.firstElementFor(elementName: "Rect", fromElement: crop) {
                            viewport.cropRect = CropRect()
                            viewport.cropRect?.x = Double(self.firstElementFor(elementName: "X", fromElement: cropRect)?.stringValue ?? "") ?? 0
                            viewport.cropRect?.y = Double(self.firstElementFor(elementName: "Y", fromElement: cropRect)?.stringValue ?? "") ?? 0
                            viewport.cropRect?.width = Double(self.firstElementFor(elementName: "Width", fromElement: cropRect)?.stringValue ?? "") ?? 0
                            viewport.cropRect?.height = Double(self.firstElementFor(elementName: "Height", fromElement: cropRect)?.stringValue ?? "") ?? 0
                        }
                        if var cropPoly = self.firstElementFor(elementName: "Poly", fromElement: crop) {
                            viewport.cropPoly = CropPoly()
                            cropPoly.elements(forName: "Vertex").forEach {
                                guard let vertex = $0 as? DDXMLElement else { return }
                                let vwPoint = VWPoint()
                                vwPoint.x = Double(self.firstElementFor(elementName: "x", fromElement: vertex)?.stringValue ?? "") ?? 0
                                vwPoint.y = Double(self.firstElementFor(elementName: "y", fromElement: vertex)?.stringValue ?? "") ?? 0
                                viewport.cropPoly?.vertices.append(vwPoint)
                            }
                        }
                        if var cropOval = self.firstElementFor(elementName: "Oval", fromElement: crop) {
                            viewport.cropOval = CropOval()
                            let center = VWPoint()
                            center.x = Double(self.firstElementFor(elementName: "CenterX", fromElement: cropOval)?.stringValue ?? "") ?? 0
                            center.y = Double(self.firstElementFor(elementName: "CenterY", fromElement: cropOval)?.stringValue ?? "") ?? 0
                            viewport.cropOval?.center = center
                            
                            let radius = VWPoint()
                            radius.x = Double(self.firstElementFor(elementName: "RadiusX", fromElement: cropOval)?.stringValue ?? "") ?? 0
                            radius.y = Double(self.firstElementFor(elementName: "RadiusY", fromElement: cropOval)?.stringValue ?? "") ?? 0
                            viewport.cropOval?.radius = radius
                        }
                    }
                    
                    pageData.viewports.append(viewport)
                }
            }
            self.pages.append(pageData)
        }
    }
    
    
    
    func firstElementFor(elementName: String, fromElement: DDXMLElement) -> DDXMLElement? {
        fromElement.elements(forName: elementName).first
    }
    
    func parseFloat3(_ vec3Element: DDXMLElement?) -> float3 {
        var result = float3()
        guard let vecString = vec3Element?.stringValue else { return result }
        
        let parts = vecString.components(separatedBy: ",")
        if parts.count == 3 {
            result.x = Float(parts[0]) ?? 0.0
            result.y = Float(parts[1]) ?? 0.0
            result.z = Float(parts[2]) ?? 0.0
        }
        
        return result
    }
    
    func parseFloat2(_ vecElement: DDXMLElement?) -> float2 {
        var result = float2()
        guard let vecString = vecElement?.stringValue else { return result }
        
        let parts = vecString.components(separatedBy: ",")
        if parts.count == 2 {
            result.x = Float(parts[0]) ?? 0.0
            result.y = Float(parts[1]) ?? 0.0
        }
        
        return result
    }
    
    func parseCGRect(_ vec4Element: DDXMLElement?) -> CGRect {
        var result = CGRect.zero
        guard let vecString = vec4Element?.stringValue else { return result }
        
        let parts = vecString.components(separatedBy: ",")
        if parts.count == 4 {
            let left = Double(parts[0]) ?? 0.0
            let right = Double(parts[1]) ?? 0.0
            let bottom = Double(parts[2]) ?? 0.0
            let top = Double(parts[3]) ?? 0.0
            result = CGRect(x: left, y: top, width: right-left, height: top-bottom)
        }
        
        return result
    }
}
