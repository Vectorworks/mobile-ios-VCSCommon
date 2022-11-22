import Foundation
import RealmSwift

struct Snap {
    public static func construct(relatedTo file: FileAsset, withName name: String) -> UploadJobLocalFile? {
        return GenericFile.construct(relatedTo: file, withName: name, withExtension: VCSFileType.VWSNAP)
    }
}

struct Measurement {
    public static func construct(relatedTo file: FileAsset, withName name: String) -> UploadJobLocalFile? {
        return GenericFile.construct(relatedTo: file, withName: name, withExtension: VCSFileType.XMLZIP)
    }
}

public struct Photo {
    public static func construct(withName name: String, tempFile: URL, containerInfo: ContainingFolderMetadata, owner: String) -> UploadJobLocalFile? {
        let newName = name.pathExtension.lowercased() == Photo.fileExtension ? name : name.appendingPathExtension(Photo.fileExtension)
        let localFileForUpload = UploadJobLocalFile(ownerLogin: owner,
                                                    storageType: containerInfo.storageType,
                                                    prefix: containerInfo.prefix.appendingPathComponent(newName),
                                                    tempFileURL: tempFile,
                                                    related: [])
        
        return localFileForUpload
    }
    
    public static let fileExtension = VCSFileType.JPG.rawValue.lowercased()
}

struct PDF {
    static func construct(relatedTo file: FileAsset, withName name: String, PDFTempFile: URL, thumbnail: UploadJobLocalFile?) -> UploadJobLocalFile? {
        
        let measurement = Measurement.construct(relatedTo: file, withName: name)
        let snap = Snap.construct(relatedTo: file, withName: name)
        
        let relatedFiles = [measurement, snap, thumbnail].compactMap { $0 }
        
        let localFileForUpload = UploadJobLocalFile(ownerLogin: file.ownerLogin,
                                                    storageType: StorageType.typeFromString(type: file.storageTypeString),
                                                    prefix: file.prefix.replacingOccurrences(of: file.name, with: name),
                                                    tempFileURL: PDFTempFile,
                                                    related: relatedFiles)
        
        return localFileForUpload
    }
    
    static func constructFromFilesApp(ownerLogin: String, storageType: StorageType, prefix: String, fileURL: URL, thumbnail: UploadJobLocalFile? = nil) -> UploadJobLocalFile? {
        let relatedFiles = [thumbnail].compactMap { $0 }
        
        let localFileForUpload = UploadJobLocalFile(ownerLogin: ownerLogin,
                                                    storageType: storageType,
                                                    prefix: prefix,
                                                    tempFileURL: fileURL,
                                                    related: relatedFiles)
        
        return localFileForUpload
    }
}

public struct GenericFile {
    public static func construct(withName name: String, pathExtention: String? = nil, fileURL: URL, containerInfo: ContainingFolderMetadata, owner: String, thumbnail: UploadJobLocalFile? = nil) -> UploadJobLocalFile? {
        var newName = name
        if let pExtention = pathExtention {
            newName = name.stringByReplacingPathExtension(pExtention) ?? name
        }
        
        let relatedFiles = [thumbnail].compactMap { $0 }
        
        let localFileForUpload = UploadJobLocalFile(ownerLogin: owner,
                                                    storageType: containerInfo.storageType,
                                                    prefix: containerInfo.prefix.appendingPathComponent(newName),
                                                    tempFileURL: fileURL,
                                                    related: relatedFiles)
        
        return localFileForUpload
    }
    
    public static func construct(relatedTo file: FileAsset, withName name: String, withExtension: VCSFileType) -> UploadJobLocalFile? {
        guard let relatedFile = file.related(withExtension: withExtension),
              let relatedFileLocalPath = relatedFile.localPathString,
              FileManager.default.fileExists(atPath: relatedFileLocalPath),
              let newName = name.stringByReplacingPathExtension(withExtension.rawValue) else { return nil }
        
        
        let relatedFileLocalURL = FileManager.uploadPath(pathExtension: withExtension.rawValue)
        guard let _ = try? FileManager.default.copyItem(at: URL(fileURLWithPath: relatedFileLocalPath), to: relatedFileLocalURL) else { return nil }
        
        let localFileForUpload = UploadJobLocalFile(ownerLogin: file.ownerLogin,
                                                    storageType: .INTERNAL,
                                                    prefix: relatedFile.prefix.replacingOccurrences(of: relatedFile.name, with: newName),
                                                    tempFileURL: relatedFileLocalURL,
                                                    related: [])
        
        return localFileForUpload
    }
}
