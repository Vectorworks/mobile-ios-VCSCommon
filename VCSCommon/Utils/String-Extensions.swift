import Foundation
import CryptoKit

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
}
