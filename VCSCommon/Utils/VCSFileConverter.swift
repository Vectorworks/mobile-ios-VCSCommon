import Foundation
import CocoaLumberjackSwift
import ModelIO

public class VCSFileConverter {
    public class func convertUSDZToOBJ(usdzPath: String, objPath: String, completion: ((Result<[String], Error>) -> Void)? = nil) {
        DispatchQueue.global().async {
            do {
                let directoryContents = try VCSFileConverter.convertUSDZToOBJ(usdzPath: usdzPath, objPath: objPath)
                completion?(.success(directoryContents))
            } catch {
                completion?(.failure(error))
            }
        }
    }
    
    public class func convertUSDZToOBJ(usdzPath: String, objPath: String) throws -> [String] {
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
            try FileManager.default.createDirectory(at: outputFilenameUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
            try mdlAsset.export(to: outputFilenameUrl)
            DDLogInfo("Successfully exported file.")
            let diff = CFAbsoluteTimeGetCurrent() - start
            DDLogInfo("Took \(diff) seconds")
            
            var directoryContents = try FileManager.default.contentsOfDirectory(atPath: outputFilenameUrl.deletingLastPathComponent().path)
            directoryContents.removeAll(where: { $0 == inputFileUrl.path })
            DDLogInfo("Exported \(directoryContents.count) files.")
            directoryContents.forEach{ DDLogInfo("Filename: \($0.lastPathComponent)") }
            
            return directoryContents
        } catch {
            DDLogError("Error converting file: \(inputFileUrl)\nWith error: \(error)")
            throw error
        }
    }
}
