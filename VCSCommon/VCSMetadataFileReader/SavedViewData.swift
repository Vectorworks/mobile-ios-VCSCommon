import Foundation

public class SavedViewData: NSObject {
    public var name: String = ""
    public var designLayers: [DesignLayerData] = []
    public var camera: CameraData?
}
