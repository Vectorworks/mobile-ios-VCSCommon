import Foundation

public class VCSJobFileInfoResponse: NSObject, Codable {
    public let fileCount: Int
    public let path: String
    public let provider: String
    
    enum CodingKeys: String, CodingKey {
        case fileCount = "file_count"
        case path
        case provider
    }
    
    init(fileCount: Int, path: String, provider: String) {
        self.fileCount = fileCount
        self.path = path
        self.provider = provider
    }
}

extension VCSJobFileInfoResponse: VCSCachable {
    public typealias RealmModel = RealmJobFileInfo
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSJobFileInfoResponse.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSJobFileInfoResponse.realmStorage.getByIdOfItem(item: self) != nil {
            VCSJobFileInfoResponse.realmStorage.partialUpdate(item: self)
        } else {
            VCSJobFileInfoResponse.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSJobFileInfoResponse.realmStorage.partialUpdate(item: self)
    }
}
