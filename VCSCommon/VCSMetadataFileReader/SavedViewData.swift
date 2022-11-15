import Foundation

@objc public class SavedViewData: NSObject {
    @objc public var name: String = ""
    @objc public var designLayers: [DesignLayerData] = []
    @objc public var camera: CameraData?
}
