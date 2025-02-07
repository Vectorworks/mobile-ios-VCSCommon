import Foundation
import Alamofire
import UIKit
import CocoaLumberjackSwift

public extension Date {
    var VCSISO8061String: String {
        return DateFormatter.ISO8061.string(from: self)
    }
    
    var ISO8601String: String {
        return ISO8601DateFormatter().string(from: self)
    }
}

internal extension DateFormatter {
    static var ISO8061: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }
    
    static var RFC1123: DateFormatter {
        let formatter = DateFormatter()
        let timeZone = TimeZone(identifier: "GMT")
        formatter.timeZone = timeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        return formatter
    }
}

public extension Encodable {
    func asDictionary() -> [String: Any] {
        var result = [String: Any]()
        if let data = try? JSONEncoder().encode(self),
            let dictionary: [String: Any] = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any] {
            result = dictionary
        }
        
        return result
    }
    
    func asJSON() -> String {
        var result: String = "{}"
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        do {
            let jsonData = try JSONEncoder().encode(self)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else { return result }
            result = jsonString
            DDLogVerbose("Encodable-asJSON data json string: \(result)")
            return result
        } catch {
            DDLogError("Encodable-asJSON error: \(error)")
            return result
        }        
    }
}

public enum ProgressValues : Double {
    case Started = -1
    case Finished = 2
}

public extension NotificationCenter {
    static func postNotification(name: Notification.Name, userInfo: [AnyHashable: Any]?) {
        DispatchQueue.main.async { NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo) }
    }
    
    static func postUploadNotification(model: FileAsset, progress: Double) {
        let notificationName = Notification.Name("uploading:\(model.rID)")
        var userInfo: [String : Any] = [:]
        userInfo["progress"] =  progress
        userInfo["model"] = model
        DispatchQueue.main.async { NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo) }
    }
    
    static func postUploadNotification(modelID: String, progress: Double) {
        let notificationName = Notification.Name("uploading:\(modelID)")
        var userInfo: [String : Any] = [:]
        userInfo["progress"] =  progress
        userInfo["modelID"] = modelID
        DispatchQueue.main.async { NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo) }
    }
    
    static func postDownloadNotification(model: FileAsset, progress: Double) {
        let notificationName = Notification.Name("downloading:\(model.rID)")
        let userInfo: [String : Any] = [
            "progress" : progress
            , "model" : model
        ]
        DispatchQueue.main.async { NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo) }
    }
    
    static func postSubFileUpdateNotification(model: VCSFileResponse) {
        let notificationName = Notification.Name("VCSUpdateLocalDataSourcesForSubFile")
        let userInfo: [String : Any] = [
            "fileID" : model.rID
            , "file" : model
        ]
        DispatchQueue.main.async { NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo) }
        
        NotificationCenter.postSubItemUpdateNotification(item: model)
    }
    
    static func postSubFolderUpdateNotification(model: VCSFolderResponse) {
        let notificationName = Notification.Name("VCSUpdateLocalDataSourcesForSubFolder")
        let userInfo: [String : Any] = [
            "folderID" : model.rID
            , "folder" : model
        ]
        DispatchQueue.main.async { NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo) }
        
        NotificationCenter.postSubItemUpdateNotification(item: model)
    }
    
    static func postSubItemUpdateNotification(model: Asset) {
        if model.isFile, let file = model as? VCSFileResponse {
            NotificationCenter.postSubFileUpdateNotification(model: file)
        } else if let folder = model as? VCSFolderResponse {
            NotificationCenter.postSubFolderUpdateNotification(model: folder)
        } else {
            NotificationCenter.postSubItemUpdateNotification(item: model)
        }
    }
    
    private static func postSubItemUpdateNotification(item: Asset) {
        let notificationName = Notification.Name("VCSUpdateLocalDataSourcesForSubItem")
        let userInfo: [String : Any] = [
            "itemID" : item.rID
            , "item" : item
        ]
        DispatchQueue.main.async { NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo) }
    }
}

public extension FileManager {
    class var AppDocumentsDirectoryURL: URL { return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] }
    
    class var AppDocumentsDirectory: String { return FileManager.AppDocumentsDirectoryURL.path }
    
    class var AppDownloadDirectory: URL {
        let result = FileManager.AppDocumentsDirectoryURL.appendingPathComponent("Downloads")
        try? FileUtils.createURL(result)
        return result
    }
    
    class var AppUploadsDirectory: URL {
        let result = FileManager.AppDocumentsDirectoryURL.appendingPathComponent("ToBeUploaded")
        try? FileUtils.createURL(result)
        return result
    }
    
    class var AppImportDirectory: URL {
        let result = FileManager.AppDocumentsDirectoryURL.appendingPathComponent("Imported")
        try? FileUtils.createURL(result)
        return result
    }
    
    class var AppMeasurementsDirectory: String {
        let result = FileManager.AppDocumentsDirectoryURL.appendingPathComponent("Measurements")
        try? FileUtils.createURL(result)
        return result.path
    }
    
    class var AppShareExtDirectory: URL {
        let result = FileManager.AppDocumentsDirectoryURL.appendingPathComponent("ShareExt")
        try? FileUtils.createURL(result)
        return result
    }
    
    class var AppTempDirectory: String {
        let tmp = NSTemporaryDirectory()
        try? FileUtils.createPath(tmp)
        return tmp
    }
    
    class var AppTempDirectoryURL: URL {
        return URL(fileURLWithPath: self.AppTempDirectory)
    }
    
    class var AppBurstPhotosTempDirectory: String {
        let path = self.AppTempDirectory.appendingPathComponent("BurstPhotos")
        try? FileUtils.createPath(path)
        return path
    }
    
    class func downloadPath(uuidString: String, pathExtension: String) -> URL {
        let fileName = uuidString.appendingPathExtension(pathExtension)
        let result = FileManager.downloadPath(fileName: fileName)
        return result
    }
    
    class func brandingCacheURL(fileName: String) -> URL {
        let brandingURL = FileManager.AppDownloadDirectory.appendingPathComponent("branding")
        try? FileUtils.createURL(brandingURL)
        
        return brandingURL.appendingPathComponent(fileName)
    }
    
    class func downloadPath(fileName: String) -> URL {
        let result = FileManager.AppDownloadDirectory.appendingPathComponent(fileName)
        return result
    }
    
    class func uploadPath(uuidString: String = VCSUUID().shortenString(), pathExtension: String) -> URL {
        let fileName = uuidString.appendingPathExtension(pathExtension)
        let result = FileManager.uploadPath(fileName: fileName)
        return result
    }
    
    class func uploadPath(fileName: String) -> URL {
        let uploadsURL = FileManager.AppUploadsDirectory
        let result = uploadsURL.appendingPathComponent(fileName)
        return result
    }
    
    class func uploadPath(folderName: String) -> URL {
        let uploadsURL = FileManager.AppUploadsDirectory
        let result = uploadsURL.appendingPathComponent(folderName)
        return result
    }
    
    class func importPath(uuidString: String = VCSUUID().shortenString(), pathExtension: String) -> URL {
        let fileName = uuidString.appendingPathExtension(pathExtension)
        let result = FileManager.importPath(fileName: fileName)
        return result
    }
    
    class func importPath(fileName: String) -> URL {
        let uploadsURL = FileManager.AppImportDirectory
        let result = uploadsURL.appendingPathComponent(fileName)
        return result
    }
}

public extension URL {
    var toLocalUUID: String {
        var result = self
        result.deletePathExtension()
        return result.lastPathComponent
    }
    
    var fileSizeString: String {
        let result = String((try? self.resourceValues(forKeys:[.fileSizeKey]).fileSize) ?? 0)
        return result
    }
    
    var exists: Bool {
        return FileManager.default.fileExists(atPath: self.path)
    }
    
    var removingQueries: URL {
        return URL(string: absoluteString.removingQueries) ?? self
    }
}

public extension UIImage
{
    // MARK: Correct UIImage Orientation
    func fixedOrientation() -> UIImage
    {
        if imageOrientation == .up
        {
            return self
        }
        
        var transform:CGAffineTransform = .identity
        switch imageOrientation
        {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height).rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0).rotated(by: .pi/2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height).rotated(by: -.pi/2)
        default: break
        }
        
        switch imageOrientation
        {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0).scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0).scaledBy(x: -1, y: 1)
        default: break
        }
        
        let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                            bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0,
                            space: cgImage!.colorSpace!, bitmapInfo: cgImage!.bitmapInfo.rawValue)!
        ctx.concatenate(transform)
        
        switch imageOrientation
        {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.height,height: size.width))
        default:
            ctx.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.width,height: size.height))
        }
        return UIImage(cgImage: ctx.makeImage()!)
    }
}

public extension Error {
    var responseCode: Int {
        return self.asAFError?.responseCode ?? (self as NSError).code
    }
    
    var asFutureWrapperError: FutureWrapperError? {
        return self as? FutureWrapperError
    }
}

public enum VCSNetworkErrorCode: Int {
    case noInternet = 13
    case explicitlyCancelled = 15
    case unauthorised = 401
    case forbidden = 403
    case notFound = 404
    case preconditionRequired = 428
    
    public var responseCode: Int {
        return self.rawValue
    }
}

public extension Data {
    /// count as String.
    var size: String {
        return String(self.count)
    }
}

public extension Dictionary {
    var jsonData: Data? { return try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]) }
    
    func toJSONString() -> String? {
        guard let jsonData = jsonData else { return nil }
        
        return String(data: jsonData, encoding: .utf8)
    }
}
