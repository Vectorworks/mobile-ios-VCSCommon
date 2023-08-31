import SwiftUI
import CocoaLumberjackSwift

public typealias FilesSavedResult = Result<[LocalFileNameAndPath], Error>
public typealias FilesSavedActionResult = (FilesSavedResult) -> Void

public class LocalFileNameAndPath: ObservableObject {
    @Published public var itemName: String
    @Published public var itemPathExtension: String
    @Published public private(set) var itemURL: URL
    @Published public private(set) var thumbnailURL: URL?
    
    public init(fileAsset: FileAsset, thumbnailURL: URL? = nil) {
        self.itemName = fileAsset.name
        self.itemPathExtension = fileAsset.name.pathExtension
        self.itemURL = URL(filePath: fileAsset.localPathString ?? "")
        self.thumbnailURL = thumbnailURL
    }
    
    public init(itemName: String,
                itemPathExtension: String,
                itemURL: URL,
                thumbnailURL: URL? = nil) {
        self.itemName = itemName.deletingPathExtension
        self.itemPathExtension = itemPathExtension
        self.itemURL = itemURL
        self.thumbnailURL = thumbnailURL
    }
    
    public init(itemName: String,
                itemURL: URL,
                thumbnailURL: URL? = nil) {
        self.itemName = itemName.deletingPathExtension
        self.itemPathExtension = itemURL.pathExtension
        self.itemURL = itemURL
        self.thumbnailURL = thumbnailURL
    }
    
    public init(itemURL: URL,
                thumbnailURL: URL? = nil) {
        self.itemName = itemURL.lastPathComponent.deletingPathExtension
        self.itemPathExtension = itemURL.pathExtension
        self.itemURL = itemURL
        self.thumbnailURL = thumbnailURL
    }
    
    public static func copyFile(itemURL: URL) -> LocalFileNameAndPath? {
        return LocalFileNameAndPath.copyFile(itemName: itemURL.lastPathComponent.deletingPathExtension, itemURL: itemURL)
    }
    
    public static func copyFile(itemName: String, itemURL: URL) -> LocalFileNameAndPath? {
        let newFileURL = FileManager.uploadPath(pathExtension: itemURL.pathExtension)
        
        do {
            try FileManager.default.copyItem(at: itemURL, to: newFileURL)
            return LocalFileNameAndPath(itemName: itemName, itemURL: newFileURL)
        } catch {
            DDLogError("LocalFileNameAndPath - copyFile - error: \(error)")
        }
        
        return nil
    }
}
