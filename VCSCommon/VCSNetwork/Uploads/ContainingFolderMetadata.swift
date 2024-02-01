import Foundation

public class ContainingFolderMetadata: NSObject {
    public let ownerLogin: String
    public let storageType: StorageType
    public let prefix: String
    
    
    public init(ownerLogin: String, storageType: StorageType, prefix: String) {
        self.ownerLogin = ownerLogin
        self.storageType = storageType
        self.prefix = prefix == "/" ? "" : prefix
    }
    
    public init(folder: VCSFolderResponse) {
        self.ownerLogin = folder.ownerLogin
        self.storageType = folder.storageType
        self.prefix = folder.prefix == "/" ? "" : folder.prefix
    }
    
    public convenience init(ownerLogin: String, storageTypeString: String, prefix: String) {
        let storageType = StorageType.typeFromString(type: storageTypeString)
        self.init(ownerLogin: ownerLogin, storageType: storageType, prefix: prefix)
    }
}
