import Foundation
import CocoaLumberjackSwift
import SwiftData

@Model
public final class LocalFile {
    @Attribute(.unique)
    private(set) public var uuid: String = VCSUUID().systemUUID.uuidString
    private(set) public var name: String
    private(set) public var parent: String
    
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

extension LocalFile {
    public var exists: Bool {
        return FileManager.default.fileExists(atPath: self.localPath)
    }
    
    public var localPath: String {
        let localFileName = self.uuid.appendingPathExtension(self.name.pathExtension)
        let fileURL = FileManager.downloadPath(fileName: localFileName)
        return fileURL.path
    }
}

extension LocalFile: VCSCacheable {
    public var rID: String { return uuid }
}
