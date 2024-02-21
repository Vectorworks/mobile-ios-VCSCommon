import Foundation
import ZIPFoundation

public class FileUtils: NSObject {
    public static var cacheDirectory: String {
        return FileUtils.cacheDirectoryURL.path
    }
    
    public static var cacheDirectoryURL: URL {
        let pathURLs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let result = pathURLs.first!
        try? FileUtils.createPath(result.path)
        
        return result
    }
    
    public static var tempVGMCacheDirectory: String {
        var result = FileUtils.cacheDirectoryURL
        result.appendPathComponent("VGMTempFiles")
        try? FileUtils.createPath(result.path)
        
        return result.path
    }
    
    public static var tempZipCacheDirectory: String {
        var result = FileUtils.cacheDirectoryURL
        result.appendPathComponent("XXXZIPTempFilesXXX")
        try? FileUtils.createPath(result.path)
        
        return result.path
    }
    
    public static func clearAndCreatePath(_ path: String) throws {
        try FileUtils.deleteItem(path)
        try FileUtils.createPath(path)
    }
    
    public static func createPath(_ path: String, withIntermediateDirectories createIntermediates: Bool = true, attributes: [FileAttributeKey : Any]? = nil) throws {
        if !FileManager.default.fileExists(atPath: path) {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: createIntermediates, attributes: attributes)
        }
    }
    
    public static func createURL(_ url: URL, withIntermediateDirectories createIntermediates: Bool = true, attributes: [FileAttributeKey : Any]? = nil) throws {
        if !FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: createIntermediates, attributes: attributes)
        }
    }
    
    /**
        Deletes the file at the specified path from the disk.
     */
    public static func deleteItem(_ path: String) throws {
        if FileManager.default.fileExists(atPath: path) {
            try FileManager.default.removeItem(atPath: path)
        }
    }
    
    public static func copyFile(at srcURL: URL, to dstURL: URL) throws {
        try FileUtils.createURL(dstURL.deletingLastPathComponent())
        try FileUtils.deleteItem(dstURL.path)
        try FileManager.default.copyItem(at: srcURL, to: dstURL)
    }
    
    public static func copyFile(atPath srcPath: String, toPath dstPath: String) throws {
        try FileUtils.createPath(dstPath.deletingLastPathComponent)
        try FileUtils.deleteItem(dstPath)
        try FileManager.default.copyItem(atPath: srcPath, toPath: dstPath)
    }
    
    /**
        Creates the directory and overwrites the file at the destination path.
     */
    public static func moveItem(at src: URL, to dest: URL) throws {
        try FileUtils.createPath(src.deletingLastPathComponent().path)
        try FileUtils.deleteItem(dest.path)
        try FileManager.default.moveItem(at: src, to: dest)
    }
    
    public static func unzipFile(_ path: String, to destination: String = FileUtils.tempZipCacheDirectory) throws -> [String] {
        try FileUtils.clearAndCreatePath(destination)
        try FileManager().unzipItem(at: URL(fileURLWithPath: path), to: URL(fileURLWithPath: destination))
        
        if let dirContents = try? FileManager.default.contentsOfDirectory(atPath: destination) {
            return dirContents.map { return destination.appendingPathComponent($0) }
        }
        
        return []
    }
    
    public static func unzipFile(_ path: String, to destination: String = FileUtils.tempZipCacheDirectory, progress: inout Progress) throws -> [String] {
        try FileUtils.clearAndCreatePath(destination)
        try FileManager().unzipItem(at: URL(fileURLWithPath: path), to: URL(fileURLWithPath: destination), progress: progress)
        
        if let dirContents = try? FileManager.default.contentsOfDirectory(atPath: destination) {
            return dirContents.map { return destination.appendingPathComponent($0) }
        }
        
        return []
    }
    
    public static func unzipFiles(_ paths: [String], to destination: String = FileUtils.tempZipCacheDirectory) throws -> [String] {
        var result: [String] = []
        for path in paths {
            let unzippedFilesPaths = try FileUtils.unzipFile(path, to: destination)
            result.append(contentsOf: unzippedFilesPaths)
        }
        
        return result
    }
}
