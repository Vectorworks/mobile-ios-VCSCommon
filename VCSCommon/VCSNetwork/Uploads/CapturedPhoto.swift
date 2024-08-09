import Foundation
import CocoaLumberjackSwift
import UIKit

public class CapturedPhoto {
    public let name: String
    public var pathURL: URL { return URL(fileURLWithPath: FileManager.AppBurstPhotosTempDirectory.appendingPathComponent(self.name).appendingPathExtension("jpg")) }
    
    public init(image: UIImage, name: String) {
        self.name = name
        self.saveToDisk(image: image)
    }
    
    public func saveToDisk(image: UIImage) {
        let pathToSaveURL = self.pathURL
        DDLogInfo("Saving photo to path \(pathToSaveURL.path)")
        let imageData = image.fixedOrientation().jpegData(compressionQuality: 0.95)
        try? imageData?.write(to: pathToSaveURL)
    }
}
