import Foundation
import ZIPFoundation

@objc public class FileUtils: NSObject {
    @objc public static var cacheDirectory: String {
        return FileUtils.cacheDirectoryURL.path
    }
    
    @objc public static var cacheDirectoryURL: URL {
        let pathURLs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let result = pathURLs.first!
        try? FileUtils.createPath(result.path)
        
        return result
    }
    
    @objc public static var tempVGMCacheDirectory: String {
        var result = FileUtils.cacheDirectoryURL
        result.appendPathComponent("VGMTempFiles")
        try? FileUtils.createPath(result.path)
        
        return result.path
    }
    
    @objc public static var tempZipCacheDirectory: String {
        var result = FileUtils.cacheDirectoryURL
        result.appendPathComponent("XXXZIPTempFilesXXX")
        try? FileUtils.createPath(result.path)
        
        return result.path
    }
    
    @objc public static func clearAndCreatePath(_ path: String) throws {
        try FileUtils.deleteItem(path)
        try FileUtils.createPath(path)
    }
    
    @objc public static func createPath(_ path: String, withIntermediateDirectories createIntermediates: Bool = true, attributes: [FileAttributeKey : Any]? = nil) throws {
        if !FileManager.default.fileExists(atPath: path) {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: createIntermediates, attributes: attributes)
        }
    }
    
    @objc public static func createURL(_ url: URL, withIntermediateDirectories createIntermediates: Bool = true, attributes: [FileAttributeKey : Any]? = nil) throws {
        if !FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: createIntermediates, attributes: attributes)
        }
    }
    
    /**
        Deletes the file at the specified path from the disk.
     */
    @objc public static func deleteItem(_ path: String) throws {
        if FileManager.default.fileExists(atPath: path) {
            try FileManager.default.removeItem(atPath: path)
        }
    }
    
    /**
        Creates the directory and overwrites the file at the destination path.
     */
    @objc public static func moveItem(at src: URL, to dest: URL) throws {
        try FileUtils.createPath(src.deletingLastPathComponent().path)
        try FileUtils.deleteItem(dest.path)
        try FileManager.default.moveItem(at: src, to: dest)
    }
    
    @objc public static func unzipFile(_ path: String, to destination: String = FileUtils.tempZipCacheDirectory) throws -> [String] {
        try FileUtils.createPath(destination)
        try FileManager().unzipItem(at: URL(fileURLWithPath: path), to: URL(fileURLWithPath: destination))
        
        if let dirContents = try? FileManager.default.contentsOfDirectory(atPath: destination) {
            return dirContents.map { return destination.appendingPathComponent($0) }
        }
        
        return []
    }
    
    @objc public static func unzipFiles(_ paths: [String], to destination: String = FileUtils.tempZipCacheDirectory) throws -> [String] {
        var result: [String] = []
        for path in paths {
            let unzippedFilesPaths = try FileUtils.unzipFile(path, to: destination)
            result.append(contentsOf: unzippedFilesPaths)
        }
        
        return result
    }
}
