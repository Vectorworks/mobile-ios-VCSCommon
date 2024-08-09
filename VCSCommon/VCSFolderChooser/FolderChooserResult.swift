import Foundation

public class FolderChooserResult: Codable {
    public let ownerLogin: String
    public let storageType: StorageType
    public let prefix: String
    public var fileName: String
    
    public init(ownerLogin: String, storageType: StorageType, prefix: String, fileName: String) {
        self.ownerLogin = ownerLogin
        self.storageType = storageType
        self.prefix = prefix
        self.fileName = fileName
    }
}
