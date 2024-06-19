import Foundation
import RealmSwift

public protocol VCSRealmObject: Object, ObjectKeyIdentifiable {
    associatedtype Model
    
    init(model: Model)
    var RealmID: String { get set }
    var entity: Model { get }
    var entityFlat: Model { get }
    var partialUpdateModel: [String: Any] { get }
}

public extension VCSRealmObject {
    var entityFlat: Model {
        return entity
    }
}

//public protocol VCSModel {
//    associatedtype RealmType: VCSRealmObject
//}
