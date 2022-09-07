import Foundation
import CocoaLumberjackSwift
import ModelIO

public class VCSFileConverter {
    public class func convertUSDZToOBJ(usdzPath: String, objPath: String, completion: ((Result<[URL], Error>) -> Void)? = nil) {
        DispatchQueue.global().async {
            do {
                let directoryContents = try VCSFileConverter.convertUSDZToOBJ(usdzPath: usdzPath, objPath: objPath)
                completion?(.success(directoryContents))
            } catch {
                completion?(.failure(error))
            }
        }
    }
    
    private class func isEmptyFile(_ url: URL) -> Bool {
        var fileSize: UInt64 = 0
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            fileSize = attr[FileAttributeKey.size] as! UInt64

            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
        } catch {
            DDLogInfo("Error: \(error)")
        }
        
        return fileSize == 0
    }
    
    public class func convertUSDZToOBJ(usdzPath: String, objPath: String) throws -> [URL] {
        let start = CFAbsoluteTimeGetCurrent()
        DDLogInfo("Start \(start) seconds")
        
        let inputFileUrl = URL(fileURLWithPath: usdzPath)
        let outputFilenameUrl = URL(fileURLWithPath: objPath)
        
        guard MDLAsset.canImportFileExtension(inputFileUrl.pathExtension) else {
            throw VCSError.GenericException("canImportFileExtension failed for: \(inputFileUrl.pathExtension)")
        }
        guard MDLAsset.canExportFileExtension(outputFilenameUrl.pathExtension) else {
            throw VCSError.GenericException("canExportFileExtension failed for: \(outputFilenameUrl.pathExtension)")
        }
        
        let mdlAsset = MDLAsset(url: inputFileUrl)
        mdlAsset.loadTextures()
        
        do {
            //try FileManager.default.createDirectory(at: outputFilenameUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
            try mdlAsset.export(to: outputFilenameUrl)
            DDLogInfo("Successfully exported file.")
            let diff = CFAbsoluteTimeGetCurrent() - start
            DDLogInfo("Took \(diff) seconds")
            
            let outputFilesDirectory: URL = outputFilenameUrl.deletingLastPathComponent()
            let directoryContentsFilenames = try FileManager.default.contentsOfDirectory(atPath: outputFilesDirectory.path)
            var directoryContents: [URL] = directoryContentsFilenames.map{ outputFilesDirectory.appendingPathComponent($0) }
            
            directoryContents.removeAll(where: {
                return $0 == inputFileUrl || isEmptyFile($0)
            })
            
            DDLogInfo("Exported \(directoryContents.count) files.")
            directoryContents.forEach{ DDLogInfo("Filename: \($0.lastPathComponent)") }
            
            return directoryContents
        } catch {
            DDLogError("Error converting file: \(inputFileUrl)\nWith error: \(error)")
            throw error
        }
    }
}
