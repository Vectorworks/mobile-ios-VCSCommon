import Foundation

public class DesignLayerData: NSObject {
    var ID: UInt = 0
    var name: String = ""
    var visibility: Int = 0
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let objectToCompare = object as? DesignLayerData else { return false }
        return objectToCompare.ID == self.ID
    }
}
