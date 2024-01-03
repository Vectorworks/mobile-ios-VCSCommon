import SwiftUI
import CocoaLumberjackSwift

public typealias FilesSavedResult = Result<[LocalFileNameAndPath], Error>
public typealias FilesSavedActionResult = (FilesSavedResult) -> Void

public class LocalFileNameAndPath: ObservableObject {
    public enum Types: String {
        case none
        case thumbnail
        case arwm
    }
    @Published public var itemName: String
    @Published public var itemPathExtension: String
    @Published public private(set) var itemURL: URL
    @Published public private(set) var type: Types = .none
    @Published public private(set) var related: [LocalFileNameAndPath]
    
    public init(fileAsset: FileAsset, 
                related: [LocalFileNameAndPath] = []) {
        self.itemName = fileAsset.name.deletingPathExtension
        self.itemPathExtension = fileAsset.name.pathExtension
        self.itemURL = URL(filePath: fileAsset.localPathString ?? "")
        self.related = related
    }
    
    public init(itemName: String,
                itemPathExtension: String,
                itemURL: URL,
                related: [LocalFileNameAndPath] = []) {
        self.itemName = itemName.deletingPathExtension
        self.itemPathExtension = itemPathExtension
        self.itemURL = itemURL
        self.related = related
    }
    
    public init(itemName: String,
                itemURL: URL,
                related: [LocalFileNameAndPath] = []) {
        self.itemName = itemName.deletingPathExtension
        self.itemPathExtension = itemURL.pathExtension
        self.itemURL = itemURL
        self.related = related
    }
    
    public init(itemURL: URL,
                related: [LocalFileNameAndPath] = [],
                type: Types = .none) {
        self.itemName = itemURL.lastPathComponent.deletingPathExtension
        self.itemPathExtension = itemURL.pathExtension
        self.itemURL = itemURL
        self.related = related
        self.type = type
    }
    
    public static func copyFile(itemURL: URL) -> LocalFileNameAndPath? {
        return LocalFileNameAndPath.copyFile(itemName: itemURL.lastPathComponent.deletingPathExtension, itemURL: itemURL)
    }
    
    public static func copyFile(itemName: String, itemURL: URL) -> LocalFileNameAndPath? {
        let newFileURL = FileManager.uploadPath(pathExtension: itemURL.pathExtension)
        
        do {
            try FileUtils.copyFile(at: itemURL, to: newFileURL)
            return LocalFileNameAndPath(itemName: itemName, itemURL: newFileURL)
        } catch {
            DDLogError("LocalFileNameAndPath - copyFile - error: \(error)")
        }
        
        return nil
    }
}
