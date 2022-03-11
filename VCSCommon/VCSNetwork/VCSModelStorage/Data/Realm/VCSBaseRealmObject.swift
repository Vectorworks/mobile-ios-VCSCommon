import Foundation
import RealmSwift

public protocol VCSRealmObject: Object {
    associatedtype Model
    
    init(model: Model)
    var RealmID: String { get set }
    var entity: Model { get }
    var partialUpdateModel: [String: Any] { get }
}

//public protocol VCSModel {
//    associatedtype RealmType: VCSRealmObject
//}
