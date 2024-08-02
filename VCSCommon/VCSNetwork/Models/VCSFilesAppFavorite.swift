import Foundation
import SwiftData

@Model
public final class VCSFilesAppFavoriteRank {
    public let favoriteRank: Int
    public var realmID: String = VCSUUID().systemUUID.uuidString
    
    public init(favoriteRank: Int, realmID: String) {
        self.realmID = realmID
        self.favoriteRank = favoriteRank
    }
}

extension VCSFilesAppFavoriteRank: VCSCacheable {
    public var rID: String { return realmID }
}
