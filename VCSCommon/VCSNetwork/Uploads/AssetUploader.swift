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

@objc public class AssetUploader: NSObject {
    @objc public static var shared: AssetUploader = AssetUploader()
    @objc public class func useNewUploadLogic() -> Bool { return true }
    public var isUploadingQueued: Bool = false
    
    @objc public class func removeUploadedFileIDFromAPIClient(_ rID: String) {
        APIClient.uploads[rID] = nil
    }
    
    @objc public class func removeUploadedFileFromAPIClient(_ asset: Asset) {
        AssetUploader.removeUploadedFileIDFromAPIClient(asset.rID)
        (asset as? FileAsset)?.relatedFileAssets.forEach { AssetUploader.removeUploadedFileFromAPIClient($0) }
    }
    
    @objc public func upload(_ PDFTempFile: URL, pdfMetadata: FileAsset, newName name: String, thumbnail: UploadJobLocalFile?, owner: String) {
        let unuploadedPDF = PDF.construct(relatedTo: pdfMetadata, withName: name, PDFTempFile: PDFTempFile, thumbnail: thumbnail)
        
        let storage = VCSGenericRealmModelStorage<VCSFileResponse.RealmModel>()
        if let oldFile = storage.getById(id: unuploadedPDF.rID) {
            storage.delete(item: oldFile)
        }
        
        if AssetUploader.useNewUploadLogic() {
            let uploadJob = UploadJob(jobOperation: .PDFFileUpload, localFile: unuploadedPDF)
            uploadJob.addToCache()
            uploadJob.startUploadOperations() { (result) in
                NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
                switch result {
                case .success(_):
                    DDLogDebug("Successfully uploaded \(unuploadedPDF.name) and its related")
                case .failure(let error):
                    DDLogError("Error on upload. \(error.localizedDescription)")
                }
            }
        } else {
            UnuploadedFileActions.saveUnuploadedFiles([unuploadedPDF])
            Uploader.uploadSingle(file: unuploadedPDF).execute { (result) in
                AssetUploader.removeUploadedFileFromAPIClient(unuploadedPDF)
                switch result {
                case .success(_):
                    DDLogDebug("Successfully uploaded \(unuploadedPDF.name) and its related")
                    NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
                case .failure(let error):
                    DDLogError("Error on upload. \(error.localizedDescription)")
                }
            }
        }
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
    
    public func upload(_ name: String, pathExtention: String? = nil, containingFolder: ContainingFolderMetadata, tempFile: URL, owner: String, withCompletionHandler handler: ((Result<VCSFileResponse, Error>) -> Void)?) {
        let unuploadedFile = GenericFile.construct(withName: name, pathExtention: pathExtention, fileURL: tempFile, containerInfo: containingFolder, owner: owner)
        
        if AssetUploader.useNewUploadLogic() {
            let uploadJob = UploadJob(jobOperation: .SingleFileUpload, localFile: unuploadedFile)
            uploadJob.addToCache()
            uploadJob.startUploadOperations() { (result) in
                NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
                switch result {
                case .success(let value):
                    handler?(.success(value))
                case .failure(let error):
                    handler?(.failure(error))
                }
            }
        } else {
            UnuploadedFileActions.saveUnuploadedFiles([unuploadedFile])
            Uploader.uploadSingle(file: unuploadedFile).execute { (result) in
                switch result {
                case .success(let value):
                    NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
                    handler?(.success(value))
                case .failure(let error):
                    handler?(.failure(error))
                }
            }
        }
    }
    
    public func upload(uploadJob: UploadJob, withCompletionHandler handler: ((Result<[VCSFileResponse], Error>) -> Void)?) {
        if AssetUploader.useNewUploadLogic() {
            uploadJob.addToCache()
            uploadJob.startUploadOperations()
        }
    }
    
    public func upload(unuploadedFiles: [UploadJobLocalFile], owner: String, withCompletionHandler handler: ((Result<[VCSFileResponse], Error>) -> Void)?) {
        self.isUploadingQueued = true
        if AssetUploader.useNewUploadLogic() {
            let uploadJob = UploadJob(localFiles: unuploadedFiles)
            uploadJob.addToCache()
            uploadJob.startUploadOperations() { (result) in
                NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
//                switch result {
//                case .success(let value):
//                    handler?(.success(value))
//                case .failure(let error):
//                    handler?(.failure(error))
//                }
            }
        } else {
            Uploader.uploadMultiple(files: unuploadedFiles).execute(onSuccess: { (files) in
                NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
                self.isUploadingQueued = false
                handler?(.success(files))
            }) { (error) in
                self.isUploadingQueued = false
                handler?(.failure(error))
            }
        }
    }
    
    public func uploadFromFilesApp(_ fileURL: URL, ownerLogin: String, storageType: StorageType, prefix: String, thumbnail: UploadJobLocalFile? = nil, onURLSessionTaskCreation: ((URLSessionTask) -> Void)? = nil, completion: ((Result<VCSFileResponse, Error>) -> Void)? = nil) {
        let unuploadedPDF = PDF.constructFromFilesApp(ownerLogin: ownerLogin, storageType: storageType, prefix: prefix, fileURL: fileURL, thumbnail: thumbnail)
        
        Uploader.uploadSingle(file: unuploadedPDF, filesApp: true, onURLSessionTaskCreation: onURLSessionTaskCreation).execute { (result) in
            switch result {
            case .success(let file):
                DDLogDebug("Successfully uploaded \(unuploadedPDF.name) and its related")
                completion?(.success(file))
                NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
            case .failure(let error):
                DDLogError("Error on upload. \(error.localizedDescription)")
                completion?(.failure(error))
            }
        }
    }
    
    @discardableResult
    public func upload(photos: [CapturedPhoto], containingFolder: ContainingFolderMetadata, owner: String, withCompletionHandler handler: ((Result<[VCSFileResponse], Error>) -> Void)?) -> [UploadJobLocalFile] {
        let unuploadedPhotos = photos.compactMap { (photo) -> UploadJobLocalFile? in
            return Photo.construct(withName: photo.name, tempFile: photo.pathURL, containerInfo: containingFolder, owner: owner)
        }
        
        if AssetUploader.useNewUploadLogic() {
            //TODO: iiliev add completion
            let uploadJob = UploadJob(localFiles: unuploadedPhotos)
            uploadJob.addToCache()
            uploadJob.startUploadOperations() { (result) in
                NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
//                switch result {
//                case .success(let value):
//                    handler?(.success(value))
//                case .failure(let error):
//                    handler?(.failure(error))
//                }
            }
        } else {
            UnuploadedFileActions.saveUnuploadedFiles(unuploadedPhotos)
            Uploader.uploadMultiple(files: unuploadedPhotos).execute { (result) in
                switch result {
                case .success(let files):
                    NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
                    handler?(.success(files))
                case .failure(let error):
                    handler?(.failure(error))
                }
            }
        }
        
        return unuploadedPhotos
    }
    
    public func upload(photos: [PhotoCapture], containingFolder: ContainingFolderMetadata, owner: String, withCompletionHandler handler: ((Result<[VCSFileResponse], Error>) -> Void)?) -> [UploadJobLocalFile] {
        var unuploadedFiles: [UploadJobLocalFile] = []
        
        photos.forEach { (capture: PhotoCapture) in
            let image = GenericFile.construct(withName: capture.uploadImageFileName, fileURL: capture.imageLocalURL, containerInfo: containingFolder, owner: owner)
            unuploadedFiles.append(image)
            if capture.gravity != nil {
                let gravity = GenericFile.construct(withName: capture.uploadGravityFileName, fileURL: capture.gravityLocalURL, containerInfo: containingFolder, owner: owner)
                unuploadedFiles.append(gravity)
            }
            if capture.depthData != nil {
                let depth = GenericFile.construct(withName: capture.uploadDepthFileName, fileURL: capture.depthLocalURL, containerInfo: containingFolder, owner: owner)
                unuploadedFiles.append(depth)
            }
        }
        
        UnuploadedFileActions.saveUnuploadedFiles(unuploadedFiles)
        
        if AssetUploader.useNewUploadLogic() {
            //TODO: iiliev add completion
            let uploadJob = UploadJob(localFiles: unuploadedFiles)
            uploadJob.addToCache()
            uploadJob.startUploadOperations() { (result) in
                NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
//                switch result {
//                case .success(let value):
//                    handler?(.success(value))
//                case .failure(let error):
//                    handler?(.failure(error))
//                }
            }
        } else {
            Uploader.uploadMultiple(files: unuploadedFiles).execute { (result) in
                switch result {
                case .success(let files):
                    NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
                    handler?(.success(files))
                case .failure(let error):
                    handler?(.failure(error))
                }
            }
        }
        
        return unuploadedFiles
    }
    
    //MARK: - Uploading files that are queued
    public func queueUploadsFromOffline(with didFinish: ((Result<Int, Error>) -> Void)?) {
        guard APIClient.hasNetworkConnectivity else {
            didFinish?(.failure(VCSNetworkError.GenericException("Uploads from offline already queued. Discarding.")))
            return
        }
        guard let owner = AuthCenter.shared.user else {
            didFinish?(.failure(VCSNetworkError.GenericException("No AuthCenter.shared.login, any files queued for upload will not be uploaded.")))
            return
        }
        guard AssetUploader.shared.isUploadingQueued == false else {
            didFinish?(.failure(VCSNetworkError.GenericException("Uploading already started. Discarding.")))
            return
        }
        
        AssetUploader.shared.isUploadingQueued = true
        
        let localFilesForUpload = VCSGenericRealmModelStorage<RealmUploadJobLocalFile>().getAll()
        guard localFilesForUpload.isEmpty == false else {
            didFinish?(.success(0))
            return
        }
        
        var uploadsCount = 0
        AssetUploader.shared.upload(unuploadedFiles: localFilesForUpload, owner: owner.login) { (result) in
            uploadsCount += 1
            var hasFailed = false
            var lastError = VCSNetworkError.GenericException("nil - queueUploadsFromOffline") as Error
            
            switch result {
            case .success:
                DDLogDebug("OK")
            case .failure(let error):
                DDLogError("Error on upload on connection restore. \(error.localizedDescription)")
                hasFailed = true
                lastError = error
            }
            
            if (uploadsCount == localFilesForUpload.count) {
                if hasFailed {
                    didFinish?(.success(0))
                } else {
                    didFinish?(.failure(lastError))
                }
            }
            
            AssetUploader.shared.isUploadingQueued = false
        }
    }
}
