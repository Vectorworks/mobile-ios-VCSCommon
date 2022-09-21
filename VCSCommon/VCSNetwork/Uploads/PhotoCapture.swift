import AVFoundation
import Combine
import CoreGraphics
import CoreImage
import CoreMotion
import Foundation
import UIKit
import CocoaLumberjackSwift

/// This is a data object that contains one image and its associated metadata, including gravity, depth,
/// and alpha mask.
public struct PhotoCapture: Identifiable {
    /// This is the unique ID for this capture.
    public let id: UInt32
    
    /// This is the original photo object, including preview.
    public let photo: AVCapturePhoto
    
    /// This property returns the image preview. It returns a cached preview if one is available. If there's no
    /// cached preview, it creates a preview image, caches it, then returns it.
    public var previewUiImage: UIImage? { makePreview() }
    
    /// This property holds the depth data in TIFF format.
    public var depthData: Data? = nil
    
    /// This is the phone's gravity vector at the moment the phone captured the image.
    public var gravity: CMAcceleration? = nil
    
    /// This view displays the full-size image.
    public var uiImage: UIImage { return UIImage(data: photo.fileDataRepresentation()!, scale: 1.0)! }
    
    public private(set) var imageLocalURL: URL
    public private(set) var gravityLocalURL: URL
    public private(set) var depthLocalURL: URL
    public private(set) var uploadImageFileName: String
    public private(set) var uploadGravityFileName: String
    public private(set) var uploadDepthFileName: String
    
    public init(id: UInt32, photo: AVCapturePhoto, depthData: Data? = nil, gravity: CMAcceleration? = nil, imageLocalURL: URL, gravityLocalURL: URL, depthLocalURL: URL, uploadImageFileName: String, uploadGravityFileName: String, uploadDepthFileName: String) {
        self.id = id
        self.photo = photo
        self.depthData = depthData
        self.gravity = gravity
        
        self.imageLocalURL = imageLocalURL
        self.gravityLocalURL = gravityLocalURL
        self.depthLocalURL = depthLocalURL
        self.uploadImageFileName = uploadImageFileName
        self.uploadGravityFileName = uploadGravityFileName
        self.uploadDepthFileName = uploadDepthFileName
    }
    
    /// This method writes the captured images to a specified folder. This method saves the image as
    /// `IMG_<ID>.HEIC`, the depth data, if available, as `IMG_<ID>_depth.TIF`, and the gravity
    /// vector, if available, as `IMG_<ID>_gravity.TXT`.
    public func writeAllFiles() throws {
        writeImage()
        writeGravityIfAvailable()
        writeDepthIfAvailable()
    }
    
    // MARK: - Private Helpers
    private func makePreview() -> UIImage? {
        if let previewPixelBuffer = photo.previewPixelBuffer {
            let ciImage: CIImage = CIImage(cvPixelBuffer: previewPixelBuffer)
            let context: CIContext = CIContext(options: nil)
            let cgImage: CGImage = context.createCGImage(ciImage, from: ciImage.extent)!
            return UIImage(cgImage: cgImage, scale: 1.0, orientation: uiImage.imageOrientation)
        } else {
            return nil
        }
    }
    
    @discardableResult
    private func writeImage() -> Bool {
        let imageUrl = self.imageLocalURL
        DDLogDebug("Saving: \(imageUrl.path)...")
        DDLogDebug("Depth Data = \(String(describing: photo.depthData))")
        do {
            try photo.fileDataRepresentation()!
                .write(to: URL(fileURLWithPath: imageUrl.path), options: .atomic)
            return true
        } catch {
            DDLogError("Can't write image to \"\(imageUrl.path)\" error=\(String(describing: error))")
            return false
        }
    }
    
    @discardableResult
    private func writeGravityIfAvailable() -> Bool {
        guard let gravityVector = gravity else {
            DDLogWarn("No gravity vector to save!")
            return false
        }
        
        let gravityString = String(format: "%lf,%lf,%lf", gravityVector.x, gravityVector.y, gravityVector.z)
        let gravityUrl = self.gravityLocalURL
        DDLogDebug("Writing gravity metadata to: \"\(gravityUrl.path)\"...")
        do {
            try gravityString.write(toFile: gravityUrl.path, atomically: true,
                                    encoding: .utf8)
            DDLogDebug("... done.")
            return true
        } catch {
            DDLogError(
                "can't write \(gravityUrl.path) error=\(String(describing: error))")
            return false
        }
    }
    
    @discardableResult
    private func writeDepthIfAvailable() -> Bool {
        guard let depthMapData = depthData else {
            DDLogWarn("No depth data to save!")
            return false
        }
        
        let depthMapUrl = self.depthLocalURL
        DDLogDebug("Writing depth data to path=\"\(depthMapUrl.path)\"...")
        do {
            try depthMapData.write(to: URL(fileURLWithPath: depthMapUrl.path), options: .atomic)
            return true
        } catch {
            DDLogError("Can't write depth tiff to: \"\(depthMapUrl.path)\" error=\(String(describing: error))")
            return false
        }
    }
}

