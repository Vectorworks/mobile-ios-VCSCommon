//https://medium.com/device-blogs/the-many-offline-options-for-ios-apps-2922c9b3bff3
//https://www.dcordero.me/posts/data_sources_in_swift_or_howto_avoid_that_this_new_trendy_persistence_framework_determines_the_architecture_of_your_app.html
//https://github.com/matteocrippa/awesome-swift#realm

import Foundation

public protocol VCSModelStorage {
    associatedtype BaseType

    func getAll(sortKeyPath: String?, ascending: Bool) -> [BaseType]
    func getAll(predicate: NSPredicate, sortKeyPath: String?, ascending: Bool) -> [BaseType]
    
    func getById(id: String) -> BaseType?
    func getByIdOfItem(item: BaseType) -> BaseType?
    func addOrUpdate(item: BaseType)
    func addOrUpdateInWriteBlock(item: BaseType)
    func partialUpdate(item: BaseType)
    func clean()
    func deleteById(id: String)
    func delete(item: BaseType)
}
