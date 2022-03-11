import Foundation
import RealmSwift

struct Snap {
    public static func construct(relatedTo file: FileAsset, withName name: String) -> UnuploadedFile? {
        return GenericFile.construct(relatedTo: file, withName: name, withExtension: VCSFileType.VWSNAP)
    }
}

struct Measurement {
    public static func construct(relatedTo file: FileAsset, withName name: String) -> UnuploadedFile? {
        return GenericFile.construct(relatedTo: file, withName: name, withExtension: VCSFileType.XMLZIP)
    }
}

public struct Photo {
    public func construct(withName name: String, tempFile: URL, containerInfo: ContainingFolderMetadata, owner: String) -> UnuploadedFile {
        let newName = name.pathExtension.lowercased() == Photo.fileExtension ? name : name.appendingPathExtension(Photo.fileExtension)
        let metadata = LocalFileForUpload(ownerLogin: owner,
                                          storageType: containerInfo.storageType,
                                          prefix: containerInfo.prefix.appendingPathComponent(newName),
                                          size: tempFile.fileSizeString,
                                          related: [])
        
        return UnuploadedFile(metadata: metadata, tempFileURL: tempFile, related: [])
    }
    
    public static let fileExtension = VCSFileType.JPG.rawValue.lowercased()
}

struct PDF {
    static func construct(relatedTo file: FileAsset, withName name: String, PDFTempFile: URL, thumbnail: UnuploadedFile?) -> UnuploadedFile {
        
        let measurement = Measurement.construct(relatedTo: file, withName: name)
        let snap = Snap.construct(relatedTo: file, withName: name)
        
        let relatedFiles = [measurement, snap, thumbnail].compactMap { $0 }
        
        let metadata = LocalFileForUpload(ownerLogin: file.ownerLogin,
                                          storageType: StorageType.typeFromString(type: file.storageTypeString),
                                          prefix: file.prefix.replacingOccurrences(of: file.name, with: name),
                                          size: PDFTempFile.fileSizeString,
                                          related: relatedFiles.map { $0.metadata })
        
        return UnuploadedFile(metadata: metadata, tempFileURL: PDFTempFile, related: relatedFiles)
    }
    
    static func constructFromFilesApp(ownerLogin: String, storageType: StorageType, prefix: String, fileURL: URL, thumbnail: UnuploadedFile? = nil) -> UnuploadedFile {
        let relatedFiles = [thumbnail].compactMap { $0 }
        
        let metadata = LocalFileForUpload(ownerLogin: ownerLogin,
                                          storageType: storageType,
                                          prefix: prefix,
                                          size: fileURL.fileSizeString,
                                          related: relatedFiles.map { $0.metadata })
        
        return UnuploadedFile(metadata: metadata, tempFileURL: fileURL, related: relatedFiles)
    }
}

struct GenericFile {
    static func construct(withName name: String, pathExtention: String? = nil, fileURL: URL, containerInfo: ContainingFolderMetadata, owner: String, thumbnail: UnuploadedFile? = nil) -> UnuploadedFile {
        var newName = name
        if let pExtention = pathExtention {
            newName = name.stringByReplacingPathExtension(pExtention) ?? name
        }
        
        let relatedFiles = [thumbnail].compactMap { $0 }
        
        let metadata = LocalFileForUpload(ownerLogin: owner,
                                          storageType: containerInfo.storageType,
                                          prefix: containerInfo.prefix.appendingPathComponent(newName),
                                          size: fileURL.fileSizeString,
                                          related: relatedFiles.map { $0.metadata })
        
        return UnuploadedFile(metadata: metadata, tempFileURL: fileURL, related: relatedFiles)
    }
    
    public static func construct(relatedTo file: FileAsset, withName name: String, withExtension: VCSFileType) -> UnuploadedFile? {
        guard let relatedFile = file.related(withExtension: withExtension),
              let relatedFileLocalPath = relatedFile.localPathString,
              FileManager.default.fileExists(atPath: relatedFileLocalPath),
              let newName = name.stringByReplacingPathExtension(withExtension.rawValue) else { return nil }
        
        
        let relatedFileLocalURL = FileManager.uploadPath(pathExtension: withExtension.rawValue)
        guard let _ = try? FileManager.default.copyItem(at: URL(fileURLWithPath: relatedFileLocalPath), to: relatedFileLocalURL) else { return nil }
        
        let metadata = LocalFileForUpload(ownerLogin: file.ownerLogin,
                                          storageType: .INTERNAL,
                                          prefix: relatedFile.prefix.replacingOccurrences(of: relatedFile.name, with: newName),
                                          size: relatedFileLocalURL.fileSizeString,
                                          related: [])
        
        return UnuploadedFile(metadata: metadata, tempFileURL: relatedFileLocalURL, related: [])
    }
}
