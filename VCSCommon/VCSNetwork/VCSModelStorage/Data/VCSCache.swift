import Foundation
import SwiftData
import CocoaLumberjackSwift

//VCSCacheable
public protocol VCSCacheable {
    var rID: String { get }
    func addToCache(forceNilValuesUpdate: Bool, skipRootFolderID: Bool, modelContext: ModelContext)
    func addToCacheLogic(modelContext: ModelContext)
    static func getItemByID(id: String, modelContext: ModelContext) -> Self?
    static func getAll(modelContext: ModelContext) -> [Self]
    func deleteFromCache(modelContext: ModelContext)
    
}

extension VCSCacheable where Self: PersistentModel {
    public func addToCache(forceNilValuesUpdate: Bool = false, skipRootFolderID: Bool = false, modelContext: ModelContext = ModelContext(VCSCache.persistentContainer)) {
        VCSFolderResponse.addToCacheRootFolderID = nil
        if skipRootFolderID == false {
            if self is VCSFolderResponse {
                VCSFolderResponse.addToCacheRootFolderID = (self as? VCSFolderResponse)?.rID
            }
            if self is VCSShareableLinkResponse {
                VCSFolderResponse.addToCacheRootFolderID = (self as? VCSShareableLinkResponse)?.asset.rID
            }
            if self is VCSSharedWithMeAsset {
                VCSFolderResponse.addToCacheRootFolderID = (self as? VCSSharedWithMeAsset)?.asset.rID
            }
            if self is SharedLink {
                VCSFolderResponse.addToCacheRootFolderID = (self as? SharedLink)?.sharedAsset?.asset.rID
            }
        }
        
        if (forceNilValuesUpdate) {
            self.addToCacheLogic(modelContext: modelContext)
        } else {
            self.partialUpdateToCacheLgic(modelContext: modelContext)
        }
    }
    
    public func addToCacheLogic(modelContext: ModelContext) {
        modelContext.insert(self)
        if modelContext.hasChanges {
            do {
                try modelContext.save()
            } catch {
                DDLogError("VCSCacheable - addToCache \(self) error: \(error)")
            }
        }
    }
    
    private func partialUpdateToCacheLgic(modelContext: ModelContext) {
        //TODO: REALM_CHANGE
        self.addToCacheLogic(modelContext: modelContext)
    }
    
    static public func getItemByID(id: String, modelContext: ModelContext = ModelContext(VCSCache.persistentContainer)) -> Self? {
        do {
            let predicate = #Predicate<Self> { object in
                object.rID == id
            }
            var descriptor = FetchDescriptor(predicate: predicate)
            descriptor.fetchLimit = 1
            let object = try modelContext.fetch(descriptor)
            return object.first
        } catch {
            DDLogError("VCSCacheable - getItemByID(\(id) error:\(error)")
            return nil
        }
    }
    
    static public func getAll(modelContext: ModelContext = ModelContext(VCSCache.persistentContainer)) -> [Self] {
        do {
            return try modelContext.fetch(FetchDescriptor<Self>())
        } catch {
            DDLogError("VCSCacheable - getAll error: \(error)")
            return []
        }
    }
    
    public func deleteFromCache(modelContext: ModelContext = ModelContext(VCSCache.persistentContainer)) {
        modelContext.delete(self)
        if modelContext.hasChanges {
            do {
                try modelContext.save()
            } catch {
                DDLogError("VCSCacheable - addToCache \(self) error: \(error)")
            }
        }
    }
}

public class VCSCache {
    public static let persistentContainer: ModelContainer = {
        do {
            let configuration = ModelConfiguration()
            let container = try ModelContainer(for: VCSUser.self,
                                               VCSFileResponse.self,
                                               VCSFolderResponse.self,
                                               VCSSharingInfoResponse.self,
                                               VCSOwnerInfoResponse.self,
                                               SharedLink.self,
                                               VCSSharedAssetBrandingResponseWrapper.self,
                                               configurations: configuration)
            return container
        } catch {
            fatalError("Failed to create a container")
        }
    }()
}
