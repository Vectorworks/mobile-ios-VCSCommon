import Foundation
import RealmSwift
import Realm
import CocoaLumberjackSwift

public class VCSRealmDB {
    private(set) public static var  extObjectTypes: [RealmSwift.ObjectBase.Type] = [VCSSharedAssetBrandingResponse.RealmModel.self
                                                                                    ,VCSFileResponse.RealmModel.self
                                                                                    ,VCSFlagsResponse.RealmModel.self
                                                                                    ,VCSFolderResponse.RealmModel.self
                                                                                    ,VCSStorageResponse.RealmModel.self
                                                                                    ,StoragePage.RealmModel.self
                                                                                    ,VCSUser.RealmModel.self
                                                                                    
                                                                                    ,VCSOwnerInfoResponse.RealmModel.self
                                                                                    ,VCSSharingInfoResponse.RealmModel.self
                                                                                    ,LocalFile.RealmModel.self
                                                                                    ,UploadJob.RealmModel.self
                                                                                    ,UploadJobLocalFile.RealmModel.self
                                                                                    ,VCSMountPointResponse.RealmModel.self
                                                                                    ,VCSSharedWithUser.RealmModel.self
                                                                                    
                                                                                    ,RealmQuotas.self
                                                                                    ,RealmVCSAWSkeys.self
                                                                                    ,RealmBrandingLogoPosition.self
                                                                                    
                                                                                    ,VCSFilesAppTags.RealmModel.self
                                                                                    ,VCSFilesAppFavoriteRank.RealmModel.self
                                                                                    ,LocalFilesAppFile.RealmModel.self
                                                                                    
                                                                                    ,RealmJobFileVersionRequest.self
                                                                                    ,RealmPhotogramOptionsRequest.self
                                                                                    ,PhotogramJobRequest.RealmModel.self
                                                                                    ,RealmEmail.self
                                                                                    ,VCSJobResponse.RealmModel.self
                                                                                    ,RealmJobEventData.self
                                                                                    ,VCSJobFileVersionResponse.RealmModel.self
                                                                                    ,VCSJobOptionsResponse.RealmModel.self
                                                                                    ,RealmOtherLogin.self
                                                                                    ,VCSShareableLinkOwner.RealmModel.self
                                                                                    ,VCSShareableLinkResponse.RealmModel.self
                                                                                    ,VCSSharedAssetWrapper.RealmModel.self
                                                                                    ,VCSSharedAssetOWNResponse.RealmModel.self
                                                                                    ,RealmSharedFileFolderAssetWrapper.self
                                                                                    ,SharedLink.RealmModel.self
                                                                                    ,VCSSharedWithMeAsset.RealmModel.self
                                                                                    ,RealmSharedWithMeAssetWrapper.self
                                                                                    ,RealmWSharedWithInfo.self]
    private(set) public static var  appGroupRealmPathURL: URL?
    private static var  usedRealmConfig: Realm.Configuration = VCSRealmConfig.getRealmDefaultConfiguration
    public static var realm: Realm { return try! Realm(configuration: VCSRealmDB.usedRealmConfig) }
    
    public static func runMigrations(appGroup: String, extObjectTypes: [RealmSwift.ObjectBase.Type] = VCSRealmDB.extObjectTypes) {
        VCSRealmDB.extObjectTypes = extObjectTypes
        
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)?.appendingPathComponent("vcs-nomad.realm") {
            VCSRealmDB.appGroupRealmPathURL = appGroupURL
            VCSRealmDB.usedRealmConfig = VCSRealmConfig.getRealmConfiguration
        } else {
            DDLogError("Failed setting up realm with appGroud: \(appGroup)")
        }
        
        let _ = VCSRealmDB.realm
    }
    
    public static func resetDB() {
        try! VCSRealmDB.realm.write {
            VCSRealmDB.realm.deleteAll()
        }
    }
    
    public var configurationDBFileURL: URL? {
        return VCSRealmDB.realm.configuration.fileURL
    }
}

public class VCSGenericRealmModelStorage<VCSRealmModel: VCSRealmObject>: VCSModelStorage {
    public typealias BaseType = VCSRealmModel.Model
    
    public init() {}
    
    internal func getAllRealm(predicate: NSPredicate? = nil, sortKeyPath: String? = nil, ascending: Bool = true) -> Results<VCSRealmModel> {
        var result = VCSRealmDB.realm.objects(VCSRealmModel.self)
        if let filterPredicate = predicate {
            result = result.filter(filterPredicate)
        }
        if let keyPath = sortKeyPath {
            result = result.sorted(byKeyPath: keyPath, ascending: ascending)
        }
        
        return result
    }
    
    internal func getAllRealm(whereCheck: ((Query<VCSRealmModel>) -> Query<Bool>)? = nil, sortKeyPath: String? = nil, ascending: Bool = true) -> Results<VCSRealmModel> {
        var result = VCSRealmDB.realm.objects(VCSRealmModel.self)
        
        if let filterWhere = whereCheck {
            result = result.where(filterWhere)
        }
        if let keyPath = sortKeyPath {
            result = result.sorted(byKeyPath: keyPath, ascending: ascending)
        }
        
        return result
    }
    
    public func getAll(sortKeyPath: String? = nil, ascending: Bool = true) -> [BaseType] {
        return self.getAllRealm(predicate: nil, sortKeyPath: sortKeyPath, ascending: ascending).map { $0.entity }
    }
    
    public func getAll(predicate: NSPredicate, sortKeyPath: String? = nil, ascending: Bool = true) -> [BaseType] {
        return self.getAllRealm(predicate: predicate, sortKeyPath: sortKeyPath, ascending: ascending).map { $0.entity }
    }
    
    public func getAll(whereCheck: @escaping ((Query<VCSRealmModel>) -> Query<Bool>), sortKeyPath: String? = nil, ascending: Bool = true) -> [BaseType] {
        return self.getAllRealm(whereCheck: whereCheck, sortKeyPath: sortKeyPath, ascending: ascending).map { $0.entity }
    }
    
    public func getById(id: String) -> BaseType? {
        return VCSRealmDB.realm.object(ofType: VCSRealmModel.self, forPrimaryKey: id)?.entity
    }
    
    public func getModelById(id: String) -> VCSRealmModel? {
        return VCSRealmDB.realm.object(ofType: VCSRealmModel.self, forPrimaryKey: id)
    }
    
    public func getByIdOfItem(item: BaseType) -> BaseType? {
        let model = VCSRealmModel(model: item)
        return VCSRealmDB.realm.object(ofType: VCSRealmModel.self, forPrimaryKey: model.RealmID)?.entity
    }
    
    public func addOrUpdate(item: BaseType) {
        try! VCSRealmDB.realm.write {
            let model = VCSRealmModel(model: item)
            VCSRealmDB.realm.add(model, update: .all)
        }
    }
    
    public func addOrUpdateInWriteBlock(item: VCSRealmModel.Model) {
        let model = VCSRealmModel(model: item)
        VCSRealmDB.realm.add(model, update: .all)
    }
    
    public func partialUpdate(item: VCSRealmModel.Model) {
        try! VCSRealmDB.realm.write {
            let model = VCSRealmModel(model: item)
            VCSRealmDB.realm.create(VCSRealmModel.self, value: model.partialUpdateModel, update: .all)
        }
    }
    
    public func clean() {
        try! VCSRealmDB.realm.write {
            VCSRealmDB.realm.delete(VCSRealmDB.realm.objects(VCSRealmModel.self))
        }
    }
    
    public func deleteById(id: String) {
        guard let object = self.getModelById(id: id) else { return }
        try? VCSRealmDB.realm.write {
            VCSRealmDB.realm.delete(object)
        }
    }
    
    public func delete(item: VCSRealmModel.Model) {
        let id = VCSRealmModel(model: item).RealmID
        guard let model = VCSRealmDB.realm.object(ofType: VCSRealmModel.self, forPrimaryKey: id) else { return }
        try? VCSRealmDB.realm.write {
            VCSRealmDB.realm.delete(model)
        }
    }
}

public class VCSRealmConfig {
    public static var getRealmConfiguration: Realm.Configuration {
        return Realm.Configuration(
            fileURL: VCSRealmDB.appGroupRealmPathURL,
            schemaVersion: VCSRealmConfig.getRealmSchemaVersion,
            migrationBlock: VCSRealmConfig.getRealmMigrations,
            objectTypes: VCSRealmDB.extObjectTypes
        )
    }
    
    public static var getRealmDefaultConfiguration: Realm.Configuration {
        return Realm.Configuration(
            schemaVersion: VCSRealmConfig.getRealmSchemaVersion,
            migrationBlock: VCSRealmConfig.getRealmMigrations,
            objectTypes: VCSRealmDB.extObjectTypes
        )
    }
    
    private static var getRealmSchemaVersion: UInt64 { return 23 }
    private static var getRealmMigrations: RealmSwift.MigrationBlock {
        return { migration, oldSchemaVersion in
            if (oldSchemaVersion < 2) {
                migration.enumerateObjects(ofType: RealmVCSUser.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["isLoggedIn"] = false
                }
            }
            if (oldSchemaVersion < 3) {
                migration.enumerateObjects(ofType: RealmSharedLink.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["dateCreated"] = Date()
                }
            }
            if (oldSchemaVersion < 4) {
                migration.enumerateObjects(ofType: RealmSharingInfo.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["link"] = ""
                    newObject?["linkUUID"] = ""
                    newObject?["linkExpires"] = ""
                    newObject?["resourceURI"] = ""
                    
                    if let linkDetails = oldObject?["linkDetails"] as? MigrationObject {
                        if let link = linkDetails["link"] {
                            newObject?["link"] = link
                        }
                        if let linkUUID = linkDetails["uuid"] {
                            newObject?["linkUUID"] = linkUUID
                        }
                        if let linkExpires = linkDetails["expires"] {
                            newObject?["linkExpires"] = linkExpires
                        }
                        if let resourceURI = linkDetails["resourceURI"] {
                            newObject?["resourceURI"] = resourceURI
                        }
                    } else {
                        if let link = oldObject?["link"] {
                            newObject?["link"] = link
                        }
                        if let linkUUID = oldObject?["linkUUID"] {
                            newObject?["linkUUID"] = linkUUID
                        }
                        if let linkExpires = oldObject?["linkExpires"] {
                            newObject?["linkExpires"] = linkExpires
                        }
                        if let resourceURI = oldObject?["resourceURI"] {
                            newObject?["resourceURI"] = resourceURI
                        }
                    }
                }
            }
            if (oldSchemaVersion < 5) {
                migration.enumerateObjects(ofType: RealmSharedLink.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["linkName"] = nil
                    newObject?["linkThumbnailURL"] = nil
                }
            }
            if (oldSchemaVersion < 6) {
                migration.enumerateObjects(ofType: RealmFlags.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["isMounted"] = false
                }
                migration.enumerateObjects(ofType: RealmFolder.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["ownerInfo"] = nil
                }
            }
            if (oldSchemaVersion < 7) {
                migration.enumerateObjects(ofType: RealmFile.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["ownerInfo"] = nil
                }
            }
            if (oldSchemaVersion < 8) {
                migration.enumerateObjects(ofType: RealmSharedAssetBranding.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["opacity"] = 0
                    newObject?["size"] = 0
                }
            }
            if (oldSchemaVersion < 9) {
                migration.enumerateObjects(ofType: RealmJobFileVersionRequest.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["owner"] = ""
                }
            }
            if (oldSchemaVersion < 10) {
                migration.enumerateObjects(ofType: RealmFlags.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["isMountPoint"] = false
                }
            }
            if (oldSchemaVersion < 11) {
                migration.enumerateObjects(ofType: RealmFile.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["resourceID"] = UUID().uuidString
                }
                migration.enumerateObjects(ofType: RealmFolder.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["resourceID"] = UUID().uuidString
                }
            }
            if (oldSchemaVersion < 12) {
                migration.enumerateObjects(ofType: RealmFile.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["localFilesAppFile"] = nil
                }
            }
            if (oldSchemaVersion < 13) {
                migration.enumerateObjects(ofType: RealmSharedWithMeAsset.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    if oldObject?["sharedParentFolder"] == nil {
                        newObject?["sharedParentFolder"] = ""
                    }
                }
            }
            if (oldSchemaVersion < 14) {
                migration.enumerateObjects(ofType: VCSRealmStorage.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["pagesURL"] = nil
                }
            }
            if (oldSchemaVersion < 15) {
                migration.enumerateObjects(ofType: VCSRealmStorage.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["pages"] = []
                }
            }
            if (oldSchemaVersion < 16) {
                migration.enumerateObjects(ofType: RealmSharingInfo.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["allowComments"] = false
                }
            }
            if (oldSchemaVersion < 17) {
                migration.enumerateObjects(ofType: VCSRealmStoragPages.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["sharedPaths"] = List<String>()
                }
            }
            if (oldSchemaVersion < 18) {
                migration.enumerateObjects(ofType: RealmSharedWithMeAsset.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["branding"] = nil
                }
            }
            if (oldSchemaVersion < 19) {
                migration.enumerateObjects(ofType: RealmBrandingLogoPosition.className()) { (oldObject: MigrationObject?, newObject: MigrationObject?) in
                    newObject?["top"] = 0
                    newObject?["left"] = 0
                    newObject?["logoAR"] = 0
                }
            }
            if (oldSchemaVersion < 20) {
                migration.enumerateObjects(ofType: RealmUploadJob.className()) { (_, newObject: MigrationObject?) in
                    newObject?["owner"] = ""
                    migration.enumerateObjects(ofType: RealmVCSUser.className()) { oldObject, _ in
                        if (oldObject?["isLoggedIn"] as? Bool ?? false) == true {
                            newObject?["owner"] = oldObject?["RealmID"] ?? ""
                        }
                    }
                }
            }
            if (oldSchemaVersion < 21) {
                //Removed RealmFile.id
            }
            if (oldSchemaVersion < 22) {
                //Removed RealmJobOptions.refFileVersions
            }
        }
    }
}
