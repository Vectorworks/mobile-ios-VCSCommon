import Foundation

public class VCSFilesAppTags: NSObject {
    public let tagData: Data?
    public var realmID: String = VCSUUID().systemUUID.uuidString
    
    public init(tagData: Data?, realmID: String) {
        self.realmID = realmID
        self.tagData = tagData
    }
}

extension VCSFilesAppTags: VCSCachable {
    public typealias RealmModel = RealmFilesAppTags
    public static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSFilesAppTags.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSFilesAppTags.realmStorage.getByIdOfItem(item: self) != nil {
            VCSFilesAppTags.realmStorage.partialUpdate(item: self)
        } else {
            VCSFilesAppTags.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSFilesAppTags.realmStorage.partialUpdate(item: self)
    }
}
