import Foundation
import UIKit

public class CapturedPhoto: NSObject {
    public let name: String
    public var pathURL: URL { return URL(fileURLWithPath: FileManager.AppBurstPhotosTempDirectory.appendingPathComponent(self.name).appendingPathExtension("jpg")) }
    
    public init(image: UIImage, name: String) {
        self.name = name
        super.init()
        self.saveToDisk(image: image)
    }
    
    public func saveToDisk(image: UIImage) {
        let pathToSaveURL = self.pathURL
        NetworkLogger.log("Saving photo to path \(pathToSaveURL.path)")
        let imageData = image.fixedOrientation().jpegData(compressionQuality: 0.95)
        try? imageData?.write(to: pathToSaveURL)
    }
}
