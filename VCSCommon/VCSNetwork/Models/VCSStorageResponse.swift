import UIKit
import Foundation
import CocoaLumberjackSwift

public class VCSStorageResponse: Codable, Identifiable {
    public var id: String { return storageType.itemIdentifier }
    public let name, folderURI, fileURI: String
    public let storageType: StorageType
    public let resourceURI: String
    public let autoprocessParent: String?
    public let accessType: String?
    public let pagesURL: String?
    public var pages: StoragePagesList = []
    
    enum CodingKeys: String, CodingKey {
        case name
        case storageType = "storage_type"
        case folderURI = "folder_uri"
        case fileURI = "file_uri"
        case resourceURI = "resource_uri"
        case autoprocessParent = "autoprocess_parent"
        case accessType = "access_type"
        case pagesURL = "pages_url"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: CodingKeys.name)
        self.folderURI = try container.decode(String.self, forKey: CodingKeys.folderURI)
        self.fileURI = try container.decode(String.self, forKey: CodingKeys.fileURI)
        let storageTypeString = try container.decode(String.self, forKey: CodingKeys.storageType)
        let storageType = StorageType(rawValue: storageTypeString) ?? .INTERNAL
        self.storageType = storageType
        self.resourceURI = try container.decode(String.self, forKey: CodingKeys.resourceURI)
        self.autoprocessParent = try? container.decode(String.self, forKey: CodingKeys.autoprocessParent)
        self.accessType = try? container.decode(String.self, forKey: CodingKeys.accessType)
        self.pagesURL = try? container.decode(String.self, forKey: CodingKeys.pagesURL)
        self.pages = []
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: CodingKeys.name)
        try container.encode(self.folderURI, forKey: CodingKeys.folderURI)
        try container.encode(self.fileURI, forKey: CodingKeys.fileURI)
        try container.encode(self.storageType.rawValue, forKey: CodingKeys.storageType)
        try container.encode(self.resourceURI, forKey: CodingKeys.resourceURI)
        try container.encode(self.autoprocessParent, forKey: CodingKeys.autoprocessParent)
        try container.encode(self.accessType, forKey: CodingKeys.accessType)
        try container.encode(self.pagesURL, forKey: CodingKeys.pagesURL)        
    }
    
    init(name: String, folderURI: String, fileURI: String, storageType: StorageType, resourceURI: String, autoprocessParent: String?, accessType: String?, pagesURL: String?, pages: StoragePagesList) {
        self.name = name
        self.folderURI = folderURI
        self.fileURI = fileURI
        self.storageType = storageType
        self.resourceURI = resourceURI
        self.autoprocessParent = autoprocessParent
        self.accessType = accessType
        self.pagesURL = pagesURL
        self.pages = pages
    }
    
    public func loadLocalPagesList() {
        if self.pages.count == 0, let oldStorage = VCSStorageResponse.realmStorage.getById(id: self.folderURI) {
            self.pages = oldStorage.pages
        }
    }
    
    public func setStoragePagesList(storagePages: StoragePagesList) {
        self.pages.removeAll()
        self.pages.append(contentsOf: storagePages)
        VCSCache.addToCache(item: self)
    }
    
    public func storageImage() -> UIImage? {
        return UIImage(named: self.storageType.storageImageName)
    }
}

extension VCSStorageResponse {
    public static func loadUserStorages() async -> Result<StorageList, Error> {
        do {
            let storages = try await APIClient.listStorage()
            VCSUser.savedUser?.setStorageList(storages: storages)
            return .success(storages)
        } catch {
            DDLogError("VCSStorageResponse - loadUserStorages error: \(error)")
            return .failure(error)
        }
    }
}

extension VCSStorageResponse: Hashable {
    public static func == (lhs: VCSStorageResponse, rhs: VCSStorageResponse) -> Bool {
        return lhs.storageType == rhs.storageType
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(storageType)
    }
}

extension VCSStorageResponse: VCSCachable {
    public typealias RealmModel = VCSRealmStorage
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSStorageResponse.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSStorageResponse.realmStorage.getByIdOfItem(item: self) != nil {
            VCSStorageResponse.realmStorage.partialUpdate(item: self)
        } else {
            VCSStorageResponse.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSStorageResponse.realmStorage.partialUpdate(item: self)
    }
    
    public func deleteFromCache() {
        VCSStorageResponse.realmStorage.delete(item: self)
    }
}
