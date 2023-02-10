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

public extension String {
    var VCSDateFromISO8061: Date? {
        return DateFormatter.ISO8061.date(from: self)
    }
    
    var dateFromISO8601: Date? {
        return ISO8601DateFormatter().date(from: self)
    }
    
    var dateFromRFC1123: Date? {
        return DateFormatter.RFC1123.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
    
    func stringByReplacingPathExtension(_ newExtension: String) -> String? {
        return self.deletingPathExtension.appendingPathExtension(newExtension)
    }
    
    func stringByAppendingPath(path: String) -> String {
        var result = self
        guard path.count > 0 else { return result }
        
        if let serverURL = URL(string: result),
            let processedPath = path.removingPercentEncoding {
            let requestURL = serverURL.appendingPathComponent(processedPath)
            result = self.replaceDoubleSlash(input: requestURL.absoluteString)
        } else if result.count != 0 {
            if let serverURL = URL(string: path) {
                result.append(self.replaceDoubleSlash(input: serverURL.absoluteString))
            } else {
                result.append(path)
            }
        } else {
            if let serverURL = URL(string: path) {
                result = self.replaceDoubleSlash(input: serverURL.absoluteString)
            } else {
                result = path
            }
        }
        
        return result
    }
    
    func VCSNormalizedURLString() -> String {
        let result = self.hasSuffix("/") ? self : (self + "/")
        
        return result
    }
    
    private func replaceDoubleSlash(input: String) -> String {
        var result = input
        let groups = result.components(separatedBy: "//")
        if result.contains("https://") {
            if groups.count > 2 {
                result = groups.first! + "//" + groups.dropFirst().joined(separator: "/")
            }
        } else {
            result = groups.joined(separator: "/")
        }
        
        return result
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
        guard let jsonData = try? encoder.encode(self) else { return result }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else { return result }
        result = jsonString
        return result
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
    
    class func uploadPath(uuidString: String = UUID().uuidString, pathExtension: String) -> URL {
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
    
    class func importPath(uuidString: String = UUID().uuidString, pathExtension: String) -> URL {
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
}

class NetworkLogger {
    static func log(_ message: String) {
        guard APIClient.loggingEnabled else { return }
        
        NetworkLogger.log(message as Any)
    }
    
    static func log(_ item: Any) {
        guard APIClient.loggingEnabled else { return }
        
        DDLogVerbose(item)
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
    case unauthorised = 401
    case forbidden = 403
    case notFound = 404
    case preconditionRequired = 428
}

public extension Data {
    /// count as String.
    var size: String {
        return String(self.count)
    }
}

