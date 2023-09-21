import Foundation
import CryptoKit
import UniformTypeIdentifiers
import CocoaLumberjackSwift

public extension String {
    var lastPathComponent: String { return (self as NSString).lastPathComponent }
    var pathExtension: String { return (self as NSString).pathExtension }
    var deletingLastPathComponent: String { return (self as NSString).deletingLastPathComponent }
    var deletingPathExtension: String { return (self as NSString).deletingPathExtension }
    var pathComponents: [String] { return (self as NSString).pathComponents }
    var containsEmoji: Bool { return unicodeScalars.contains { $0.isEmoji } }
    
    func appendingPathComponent(_ path: String) -> String { return (self as NSString).appendingPathComponent(path) }
    func appendingPathExtension(_ ext: String) -> String { return (self as NSString).appendingPathExtension(ext) ?? ext }
    func appendingPathExtensionIfNeeded(_ ext: String) -> String { return self.pathExtension == ext ? self : self.appendingPathExtension(ext) }
    
    var MD5Hex: String {
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
        
        let result = digest.map {String(format: "%02hhx", $0)}.joined()
        return result
    }
    
    var first: Character? {
        guard isEmpty == false else { return nil }
        return self[index(startIndex, offsetBy: 0)]
    }
    
    var removingQueries: String {
        guard var components = URLComponents(string: self) else { return self }
        components.query = nil
        return components.url?.absoluteString ?? self
    }
    
    var firstCapitalized: String {
        return self.first?.uppercased() ?? "" + self.dropFirst()
    }
    
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
        if let type = UTType(filenameExtension: self.pathExtension), type.isDeclared {
            return self.deletingPathExtension.appendingPathExtension(newExtension)
        } else {
            return self.appendingPathExtension(newExtension)
        }
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
    
    var toDictionary: [String: Any]? {
        let data = Data(self.utf8)
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] {
                return dictionary
            }
        } catch let error as NSError {
            DDLogError("Failed to load: \(error.localizedDescription)")
        }
        return nil
    }
}
