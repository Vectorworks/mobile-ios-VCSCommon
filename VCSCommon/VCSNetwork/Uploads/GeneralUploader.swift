import Foundation

typealias FileWithRelatedАRGS = (uploadedFile: VCSFileResponse, uploadedRelatedFiles: [VCSFileResponse])

class Uploader {
    //Google Drive updateFromStorage does not work when there 2 files with the same name, so we need to pass the ID & verID
    static var uploadResponses: [String: VCSUploadDataResponse] = [:]
    
    static func uploadSingle(file: UploadJobLocalFile, filesApp: Bool = false, onURLSessionTaskCreation: ((URLSessionTask) -> Void)? = nil) -> Future<VCSFileResponse, Error> {
        let uploadFileData = Uploader.fileUpload(file: file, owner: file.ownerLogin)
        
        let uploadRelated: (VCSFileResponse) -> Future<FileWithRelatedАRGS, Error> = { (uploadedFile) in
            guard file.related.count > 0 else { return Future<FileWithRelatedАRGS, Error> { $0(.success((uploadedFile, []))) } }
            return Uploader.uploadRelated(related: file.related).map { (result: [VCSFileResponse]) -> FileWithRelatedАRGS in
                return (uploadedFile, result)
            }
        }
        
        let patchPDF: (FileWithRelatedАRGS) -> Future<FileWithRelatedАRGS, Error> = { (arg: FileWithRelatedАRGS) in
            let (uploadedFile, uploadedRelatedFiles) = arg
            
            guard uploadedRelatedFiles.count > 0 else { return Future<FileWithRelatedАRGS, Error> { $0(.success((uploadedFile, []))) } }
            
            let body = ["related_files": uploadedRelatedFiles.map { $0.resourceURI }]
            if let bodyData = try? JSONSerialization.data(withJSONObject: body) {
                let uploadResponse = Uploader.uploadResponses[file.rID]
                return APIClient.patchFile(owner: file.ownerLogin, storage: file.storageType.rawValue,
                                           filePrefix: file.prefix, updateFromStorage: true, bodyData: bodyData, googleDriveID: uploadResponse?.googleDriveID, googleDriveVerID: uploadResponse?.googleDriveVerID).map { (VCSEmptyResponse) -> FileWithRelatedАRGS in
                                            return (uploadedFile, uploadedRelatedFiles) }
            } else {
                return .init(error: UploadPDFError.patchFailed)
            }
        }
        
        let getJustUploaded: (FileWithRelatedАRGS) -> Future<VCSFileResponse, Error> = { (arg: FileWithRelatedАRGS) in
            let (uploadedFile, uploadedRelatedFiles) = arg
            
            guard uploadedRelatedFiles.count > 0 else { return Future<VCSFileResponse, Error> { $0(.success(uploadedFile)) } }
            let uploadResponse = Uploader.uploadResponses[file.rID]
            
            return APIClient.fileData(owner: file.ownerLogin, storage: file.storageType.rawValue, filePrefix: file.prefix, updateFromStorage: true, googleDriveID: uploadResponse?.googleDriveID, googleDriveVerID: uploadResponse?.googleDriveVerID)
        }
        
        let updateJustUploaded: (VCSFileResponse) -> Future<VCSFileResponse, Error> = { (fileResponse) in
            Uploader.uploadResponses[file.rID] = nil
            
            if filesApp == false {
                NetworkLogger.log("SF owner - \(fileResponse.ownerLogin), storage - \(fileResponse.storageTypeString), prefix - \(fileResponse.prefix)")
                NetworkLogger.log("LF owner - \(file.ownerLogin), storage - \(file.storageTypeString), prefix - \(file.prefix)")
                AssetUploader.updateUploadedFile(fileResponse, withLocalFileForUnuploadedFile: file)
            }
            VCSCache.addToCache(item: fileResponse)
            if filesApp == false {
                UnuploadedFileActions.deleteUnuploadedFiles([file])
            }
            return Future(result: .success(fileResponse))
        }
        
        
        return uploadFileData
            .andThen(uploadRelated)
            .andThen(patchPDF)
            .andThen(getJustUploaded)
            .andThen(updateJustUploaded)
    }
    
    static func fileUpload(file: UploadJobLocalFile, owner: String, onURLSessionTaskCreation: ((URLSessionTask) -> Void)? = nil) -> Future<VCSFileResponse, Error> {
        let uploadData: (VCSUploadURL) -> Future<VCSUploadDataResponse, Error> = { (url) in
            return APIClient.uploadFileURL(fileURL: file.uploadPathURL, uploadURL: url, progressForFile: file, onURLSessionTaskCreation: onURLSessionTaskCreation)
        }
        
        let getJustUploaded: (VCSUploadDataResponse) -> Future<VCSFileResponse, Error> = { (uploadResponse: VCSUploadDataResponse) in
            return APIClient.fileData(owner: owner, storage: file.storageType.rawValue, filePrefix: file.prefix, updateFromStorage: true, googleDriveID: uploadResponse.googleDriveID, googleDriveVerID: uploadResponse.googleDriveVerID)
        }
        
        return APIClient.getUploadURL(owner: owner, storage: file.storageType.rawValue, filePrefix: file.prefix, size: Int(file.size) ?? 0)
            .andThen(uploadData)
            .andThen(getJustUploaded)
    }
    
    static func uploadMultiple(files: [UploadJobLocalFile]) -> Future<[VCSFileResponse], Error> {
        let uploadSingleFile = UploadHelper.uploadSingleWithOwner()
        return FutureWrapper.execute(uploadSingleFile, onFiles: files)
    }
    
    static func uploadRelated(related: [UploadJobLocalFile]) -> Future<[VCSFileResponse], Error> {
        let uploadFile = UploadHelper.fileUplaodWithOwner()
        return FutureWrapper.execute(uploadFile, onFiles: related)
    }
}

class UploadHelper {
    static func uploadSingleWithOwner() -> ((UploadJobLocalFile) -> Future<VCSFileResponse, Error>) {
        return { (file) in
            Uploader.uploadSingle(file: file)
        }
    }
    
    static func fileUplaodWithOwner() -> ((UploadJobLocalFile) -> Future<VCSFileResponse, Error>) {
        return { (file) in
            Uploader.fileUpload(file: file, owner: file.ownerLogin)
        }
    }
}

public class Downloader {
    public static func downloadMultiple(files: [VCSFileResponse]) -> Future<[String], Error> {
        let download: (VCSFileResponse) -> Future<String, Error> = { (file) in APIClient.download(file: file) }
        return FutureWrapper.execute(download, onFiles: files)
    }
}

public struct FutureWrapperError: Error {
    public let failedErrors: Array<Error>
    public let failedFiles: Array<Any>
}

private struct FutureWrapper {
    static func execute<FileBefore, FileAfter>(_ method: @escaping ((FileBefore) -> Future<FileAfter, Error>), onFiles files: [FileBefore]) -> Future<[FileAfter], Error> {
        return Future<[FileAfter], Error> { (completion) in
            DispatchQueue.global(qos: .userInitiated).async {
                var futureFiles = [FileAfter]()
                var failedFiles = [FileBefore]()
                var failedErrors = [Error]()
                
                let group = DispatchGroup()
                files.forEach { (file) in
                    group.enter()
                    let syncSemaphore = DispatchSemaphore(value: 0)
                    
                    method(file).execute { (result) in
                        switch result {
                        case .failure(let error):
                            failedFiles.append(file)
                            failedErrors.append(error)
                            print(error)
                            // decide how to handle failure k number of files, 0 < k < filesToUpload.count -GKK
                            if (failedFiles.count + futureFiles.count == files.count) {
                                group.notify(queue: .main) {
                                    completion(.failure(FutureWrapperError(failedErrors: failedErrors, failedFiles: failedFiles)))
                                }
                            }
                        case .success(let future):
                            futureFiles.append(future)
                            if (failedFiles.count + futureFiles.count == files.count) {
                                group.notify(queue: .main) {
                                    completion(.success(futureFiles))
                                }
                            }
                        }
                        group.leave()
                        syncSemaphore.signal()
                    }
                    
                    syncSemaphore.wait()
                }
            }
        }
    }
}
