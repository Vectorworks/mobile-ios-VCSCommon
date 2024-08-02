import Foundation
import SwiftData

@Model
public final class LocalFilesAppFile {
    
    public static var rootFilesAppURL: URL?
    
    @Attribute(.unique)
    private(set) public var VCSID: String
    private(set) public var pathSuffix: String
    
    
    public init(VCSID: String, pathSuffix: String) {
        self.VCSID = VCSID
        self.pathSuffix = pathSuffix
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

extension LocalFilesAppFile {
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
}

extension LocalFilesAppFile: VCSCacheable {
    public var rID: String { return VCSID }
}
