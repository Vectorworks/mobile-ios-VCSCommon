import Foundation
import RealmSwift

public class RealmFlags: Object, VCSRealmObject {
    public typealias Model = VCSFlagsResponse
    
    @Persisted(primaryKey: true) public var RealmID: String = "nil"
    @Persisted var isNameValid: Bool = false
    @Persisted var isFileTypeSupported: Bool = false
    @Persisted var isNameDuplicate: Bool = true
    @Persisted var isSupported: Bool = false
    @Persisted var isMounted: Bool = false
    @Persisted var isMountPoint: Bool = false
    
    
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
