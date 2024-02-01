import Foundation
import RealmSwift

public class RealmFilesAppFavoriteRank: Object, VCSRealmObject {
    public typealias Model = VCSFilesAppFavoriteRank
    
    @Persisted(primaryKey: true) public var RealmID: String = "nil"
    @Persisted var favoriteRank: Int = 0
    
    
    public required convenience init(model: Model) {
        self.init()
        
        self.RealmID = model.realmID
        self.favoriteRank = model.favoriteRank.intValue
    }
    
    public var entity: Model {
        return VCSFilesAppFavoriteRank(favoriteRank: NSNumber(integerLiteral: self.favoriteRank), realmID: self.RealmID)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["favoriteRank"] = self.favoriteRank
        
        return result
    }
}
