import Foundation

public class VCSFilesAppFavoriteRank: NSObject {
    public let favoriteRank: NSNumber
    public var realmID: String = VCSUUID().systemUUID.uuidString
    
    public init(favoriteRank: NSNumber, realmID: String) {
        self.realmID = realmID
        self.favoriteRank = favoriteRank
    }
}

extension VCSFilesAppFavoriteRank: VCSCachable {
    public typealias RealmModel = RealmFilesAppFavoriteRank
    public static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSFilesAppFavoriteRank.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSFilesAppFavoriteRank.realmStorage.getByIdOfItem(item: self) != nil {
            VCSFilesAppFavoriteRank.realmStorage.partialUpdate(item: self)
        } else {
            VCSFilesAppFavoriteRank.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSFilesAppFavoriteRank.realmStorage.partialUpdate(item: self)
    }
    
    public func deleteFromCache() {
        VCSFilesAppFavoriteRank.realmStorage.delete(item: self)
    }
}
