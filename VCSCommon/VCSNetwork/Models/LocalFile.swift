import Foundation
import CocoaLumberjackSwift

public class LocalFile {
    private(set) public var uuid: String = VCSUUID().systemUUID.uuidString
    private(set) public var name: String
    private(set) public var parent: String
    //computed
//    private(set) public var isFolder = false
//    private(set) public var isFile = true
    public var exists: Bool {
        return FileManager.default.fileExists(atPath: self.localPath)
    }
    
    public var localPath: String {
        let localFileName = self.uuid.appendingPathExtension(self.name.pathExtension)
        let fileURL = FileManager.downloadPath(fileName: localFileName)
        return fileURL.path
    }
    
    public init(name: String, parent: String = "", uuid: String? = nil, tempFileURL: URL? = nil) {
        self.name = name
        self.parent = parent
        
        if let fileUUID = uuid {
            self.uuid = fileUUID
        }
        
        if let fileURL = tempFileURL {
            let localFileURL = URL(fileURLWithPath: self.localPath)
            do {
                try FileUtils.copyFile(at: fileURL, to: localFileURL)
            } catch {
                DDLogError("LocalFile init(name: \(error.localizedDescription)")
            }
            
        }
    }
}

extension LocalFile: Equatable {
    final public class func ==(lhs: LocalFile, rhs: LocalFile) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

extension LocalFile: VCSCachable {
    public typealias RealmModel = RealmLocalFile
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()

    public func addToCache() {
        LocalFile.realmStorage.addOrUpdate(item: self)
    }

    public func addOrPartialUpdateToCache() {
        if LocalFile.realmStorage.getByIdOfItem(item: self) != nil {
            LocalFile.realmStorage.partialUpdate(item: self)
        } else {
            LocalFile.realmStorage.addOrUpdate(item: self)
        }
    }

    public func partialUpdateToCache() {
        LocalFile.realmStorage.partialUpdate(item: self)
    }
    
    public func deleteFromCache() {
        LocalFile.realmStorage.delete(item: self)
    }
}
