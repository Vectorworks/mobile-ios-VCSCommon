import Foundation
import CocoaLumberjackSwift

enum UploadPDFError: Error {
    case patchFailed
}

fileprivate struct MetadataForVCSFileResponse {
    let owner: String
    let storage: String
    let filePrefix: String
}

public class AssetUploader {
    public static var shared: AssetUploader = AssetUploader()
    
    public class func removeUploadedFileIDFromAPIClient(_ rID: String) {
        APIClient.uploads[rID] = nil
    }
    
    public class func removeUploadedFileFromAPIClient(_ asset: Asset) {
        AssetUploader.removeUploadedFileIDFromAPIClient(asset.rID)
        (asset as? FileAsset)?.relatedFileAssets.forEach { AssetUploader.removeUploadedFileFromAPIClient($0) }
    }
    
    public func upload(_ PDFTempFile: URL, pdfMetadata: FileAsset, newName name: String, thumbnail: UploadJobLocalFile?, owner: String) {
        guard let unuploadedPDF = PDF.construct(relatedTo: pdfMetadata, withName: name, PDFTempFile: PDFTempFile, thumbnail: thumbnail) else { return }
        
        let storage = VCSGenericRealmModelStorage<VCSFileResponse.RealmModel>()
        if let oldFile = storage.getById(id: unuploadedPDF.rID) {
            storage.delete(item: oldFile)
        }
        
        let uploadJob = UploadJob(localFile: unuploadedPDF, owner: owner, parentFolder: nil)
        VCSCache.addToCache(item: uploadJob)
        uploadJob.startUploadOperations(singleFileCompletion: { (result) in
            NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
            switch result {
            case .success(_):
                DDLogDebug("Successfully uploaded \(unuploadedPDF.name) and its related")
            case .failure(let error):
                DDLogError("Error on upload. \(error.localizedDescription)")
            }
        })
    }
    
    internal static func updateUploadedFile(_ file: VCSFileResponse, withLocalFileForUnuploadedFile unuploadedFile: UploadJobLocalFile) {
        let localFile = LocalFile(name: file.name, parent: file.prefix, uuid: nil, tempFileURL: unuploadedFile.uploadPathURL)
        file.setLocalFile(localFile)
        unuploadedFile.related.forEach { (localFile: UploadJobLocalFile) in
            if let relatedFile = file.related.first(where: { (serverRelatedFile: VCSFileResponse) -> Bool in
                let serverRelatedFileExt =  VCSFileType(rawValue: serverRelatedFile.name.pathExtension)?.rawValue ?? "1"
                let localFileFileExt =  VCSFileType(rawValue: localFile.name.pathExtension)?.rawValue ?? "2"
                return serverRelatedFileExt == localFileFileExt }) {
                AssetUploader.updateUploadedFile(relatedFile, withLocalFileForUnuploadedFile: localFile)
            }
        }
    }
    
    public func upload(_ name: String, pathExtention: String? = nil, containingFolder: ContainingFolderMetadata, tempFile: URL, owner: String, thumbnail: UploadJobLocalFile? = nil, withCompletionHandler handler: ((Result<VCSFileResponse, Error>) -> Void)?) {
        guard let unuploadedFile = GenericFile.construct(withName: name, pathExtention: pathExtention, fileURL: tempFile, containerInfo: containingFolder, owner: owner, thumbnail: thumbnail) else {
            handler?(.failure(VCSError.LocalFileNotCreated))
            return
        }
        
        let uploadJob = UploadJob(localFile: unuploadedFile, owner: owner, parentFolder: nil)
        VCSCache.addToCache(item: uploadJob)
        uploadJob.startUploadOperations() { (result) in
            NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
            switch result {
            case .success(let value):
                handler?(.success(value))
            case .failure(let error):
                handler?(.failure(error))
            }
        }
    }
    
    public func upload(fileURL: URL, owner: String, storage: StorageType, prefix: String, withCompletionHandler handler: ((Result<VCSFileResponse, Error>) -> Void)?) {
        guard let unuploadedFile = GenericFile.construct(fileURL: fileURL, owner: owner, storage: storage, prefix: prefix) else {
            handler?(.failure(VCSError.LocalFileNotCreated))
            return
        }
        
        let uploadJob = UploadJob(localFile: unuploadedFile, owner: owner, parentFolder: nil)
        VCSCache.addToCache(item: uploadJob)
        uploadJob.startUploadOperations() { (result) in
            NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
            switch result {
            case .success(let value):
                handler?(.success(value))
            case .failure(let error):
                handler?(.failure(error))
            }
        }
    }
    
    public func upload(uploadJob: UploadJob, singleFileCompletion: ((Result<VCSFileResponse, Error>) -> Void)? = nil, multiFileCompletion: ((Result<[VCSFileResponse], Error>) -> Void)? = nil) {
        VCSCache.addToCache(item: uploadJob)
        uploadJob.startUploadOperations(singleFileCompletion: singleFileCompletion, multiFileCompletion: multiFileCompletion)
    }
    
    public func upload(unuploadedFiles: [UploadJobLocalFile], owner: String, withCompletionHandler handler: ((Result<[VCSFileResponse], Error>) -> Void)?) {
        let uploadJob = UploadJob(localFiles: unuploadedFiles, owner: owner, parentFolder: nil)
        VCSCache.addToCache(item: uploadJob)
        uploadJob.startUploadOperations(multiFileCompletion: { (result) in
            NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
            switch result {
            case .success(let value):
                handler?(.success(value))
            case .failure(let error):
                handler?(.failure(error))
            }
        })
    }
    
    @discardableResult
    public func upload(photos: [CapturedPhoto], containingFolder: ContainingFolderMetadata, owner: String, withCompletionHandler handler: ((Result<[VCSFileResponse], Error>) -> Void)?) -> [UploadJobLocalFile] {
        let unuploadedPhotos = photos.compactMap { (photo) -> UploadJobLocalFile? in
            return Photo.construct(withName: photo.name, tempFile: photo.pathURL, containerInfo: containingFolder, owner: owner)
        }
        
        let uploadJob = UploadJob(localFiles: unuploadedPhotos, owner: owner, parentFolder: nil)
        VCSCache.addToCache(item: uploadJob)
        uploadJob.startUploadOperations(multiFileCompletion: { (result) in
            NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
            switch result {
            case .success(let value):
                handler?(.success(value))
            case .failure(let error):
                handler?(.failure(error))
            }
        })
        
        return unuploadedPhotos
    }
    
    public func upload(photos: [PhotoCapture], containingFolder: ContainingFolderMetadata, owner: String, withCompletionHandler handler: ((Result<[VCSFileResponse], Error>) -> Void)?) -> [UploadJobLocalFile] {
        var unuploadedFiles: [UploadJobLocalFile] = []
        
        photos.forEach { (capture: PhotoCapture) in
            if let image = GenericFile.construct(withName: capture.uploadImageFileName, fileURL: capture.imageLocalURL, containerInfo: containingFolder, owner: owner) {
                unuploadedFiles.append(image)
                if capture.gravity != nil, let gravity = GenericFile.construct(withName: capture.uploadGravityFileName, fileURL: capture.gravityLocalURL, containerInfo: containingFolder, owner: owner) {
                    unuploadedFiles.append(gravity)
                }
                if capture.depthData != nil, let depth = GenericFile.construct(withName: capture.uploadDepthFileName, fileURL: capture.depthLocalURL, containerInfo: containingFolder, owner: owner) {
                    unuploadedFiles.append(depth)
                }
            }
        }
        
        let uploadJob = UploadJob(localFiles: unuploadedFiles, owner: owner, parentFolder: nil)
        VCSCache.addToCache(item: uploadJob)
        uploadJob.startUploadOperations(multiFileCompletion: { (result) in
            NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
            switch result {
            case .success(let value):
                handler?(.success(value))
            case .failure(let error):
                handler?(.failure(error))
            }
        })
        
        return unuploadedFiles
    }
    
    //MARK: - Uploading files that are queued
    public func queueUploadsFromOffline(with didFinish: ((Result<Int, Error>) -> Void)?) {
        guard APIClient.hasNetworkConnectivity else {
            didFinish?(.failure(VCSNetworkError.GenericException("Uploads from offline already queued. Discarding.")))
            return
        }
        
        let localUploadJobs = VCSGenericRealmModelStorage<UploadJob.RealmModel>().getAll()
        guard localUploadJobs.isEmpty == false else {
            didFinish?(.success(0))
            return
        }
        
        localUploadJobs.forEach { jobToUpload in
            guard jobToUpload.owner == VCSUser.savedUser?.login else { return }
            
            if jobToUpload.localFiles.allSatisfy({ $0.uploadingState != .Waiting && $0.uploadingState != .Uploading }) {
                DDLogInfo("Start Upload for job \(jobToUpload.jobID)")
                AssetUploader.shared.upload(uploadJob: jobToUpload, singleFileCompletion: { _ in
                    DDLogInfo("Finished upload for job: \(jobToUpload.jobID)")
                }, multiFileCompletion: { _ in
                    DDLogInfo("Finished upload for job: \(jobToUpload.jobID)")
                })
            }
        }
    }
}
