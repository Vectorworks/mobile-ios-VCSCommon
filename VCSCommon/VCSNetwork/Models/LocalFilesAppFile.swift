import Foundation

public class LocalFilesAppFile: NSObject {
    
    public static var rootFilesAppURL: URL?
    
    private(set) public var VCSID: String
    private(set) public var pathSuffix: String
    
    public var localURL: URL? {
        return LocalFilesAppFile.rootFilesAppURL?.appendingPathComponent(self.pathSuffix)
    }
    
    public var localContainerURL: URL? {
        return LocalFilesAppFile.rootFilesAppURL?.appendingPathComponent(self.VCSID)
    }
    
    public var exists: Bool {
        guard let localPath = self.localURL?.path else { return false }
        return FileManager.default.fileExists(atPath: localPath)
    }
    
    public init(VCSID: String, pathSuffix: String) {
        self.VCSID = VCSID
        self.pathSuffix = pathSuffix
        
        super.init()
    }
    
    public convenience init(VCSID: String, path: String) {
        let pathSuffix = path.replacingOccurrences(of: LocalFilesAppFile.rootFilesAppURL?.path ?? "", with: "")
        self.init(VCSID: VCSID, pathSuffix: pathSuffix)
    }
    
    public convenience init(VCSID: String, pathURL: URL) {
        let pathSuffix = pathURL.path.replacingOccurrences(of: LocalFilesAppFile.rootFilesAppURL?.path ?? "", with: "")
        self.init(VCSID: VCSID, pathSuffix: pathSuffix)
    }
}

extension LocalFilesAppFile: VCSCachable {
    public typealias RealmModel = RealmLocalFilesAppFile
    public static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()

    public func addToCache() {
        LocalFilesAppFile.realmStorage.addOrUpdate(item: self)
    }

    public func addOrPartialUpdateToCache() {
        if LocalFilesAppFile.realmStorage.getByIdOfItem(item: self) != nil {
            LocalFilesAppFile.realmStorage.partialUpdate(item: self)
        } else {
            LocalFilesAppFile.realmStorage.addOrUpdate(item: self)
        }
    }

    public func partialUpdateToCache() {
        LocalFilesAppFile.realmStorage.partialUpdate(item: self)
    }
}
