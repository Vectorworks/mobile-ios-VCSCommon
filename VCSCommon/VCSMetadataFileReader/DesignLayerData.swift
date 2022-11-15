import Foundation

@objc public class DesignLayerData: NSObject {
    @objc var ID: UInt = 0
    @objc var name: String = ""
    @objc var visibility: Int = 0
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let objectToCompare = object as? DesignLayerData else { return false }
        return objectToCompare.ID == self.ID
    }
}
