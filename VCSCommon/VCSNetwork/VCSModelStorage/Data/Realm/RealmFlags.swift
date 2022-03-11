import Foundation
import RealmSwift

public class RealmFlags: Object, VCSRealmObject {
    public typealias Model = VCSFlagsResponse
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var isNameValid: Bool = false
    @objc dynamic var isFileTypeSupported: Bool = false
    @objc dynamic var isNameDuplicate: Bool = true
    @objc dynamic var isSupported: Bool = false
    @objc dynamic var isMounted: Bool = false
    @objc dynamic var isMountPoint: Bool = false
    
    
    public required convenience init(model: Model) {
        self.init()
        
        self.RealmID = model.realmID
        self.isNameValid = model.isNameValid
        self.isFileTypeSupported = model.isFileTypeSupported
        self.isNameDuplicate = model.isNameDuplicate
        self.isSupported = model.isSupported
        self.isMounted = model.isMounted
        self.isMountPoint = model.isMountPoint
    }
    
    public var entity: Model {
        return VCSFlagsResponse(isNameValid: self.isNameValid, isFileTypeSupported: self.isFileTypeSupported, isNameDuplicate: self.isNameDuplicate, isSupported: self.isSupported, isMounted: self.isMounted, isMountPoint: self.isMountPoint, realmID: self.RealmID)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["isNameValid"] = self.isNameValid
        result["isFileTypeSupported"] = self.isFileTypeSupported
        result["isNameDuplicate"] = self.isNameDuplicate
        result["isSupported"] = self.isSupported
        result["isMounted"] = self.isMounted
        result["isMountPoint"] = self.isMountPoint
        
        return result
    }
}
