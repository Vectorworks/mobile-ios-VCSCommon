import Foundation

@objc public class ContainingFolderMetadata: NSObject {
    public let ownerLogin: String
    public let storageType: StorageType
    public let prefix: String
    
    
    public init(ownerLogin: String, storageType: StorageType, prefix: String) {
        self.ownerLogin = ownerLogin
        self.storageType = storageType
        self.prefix = prefix == "/" ? "" : prefix
    }
    
    @objc public convenience init(ownerLogin: String, storageTypeString: String, prefix: String) {
        let storageType = StorageType.typeFromString(type: storageTypeString)
        self.init(ownerLogin: ownerLogin, storageType: storageType, prefix: prefix)
    }
}
