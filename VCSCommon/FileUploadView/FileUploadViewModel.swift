import SwiftUI
import CocoaLumberjackSwift

public class FileUploadViewModel: ObservableObject {
    @Published public var folderResult: Result<VCSFolderResponse, Error>?
    @Published public var itemsLocalNameAndPath: [LocalFileNameAndPath]
    @Published public var itemsUploading: [URL: String] = [:]
    @Published public var itemsUploadProgress: [String: Double] = [:]
    @Published public var doneUploading = false
    @Published public var isUploading = false
    @Published public var completedUnitCount = 0.0
    @Published public var totalUnitCount = 0.0
    
    public var jobFilesCallback: (([UploadJobLocalFile]) -> Void)? = nil
    public var uploadCompletion: ((Result<[VCSFileResponse], Error>) -> Void)? = nil
    
    public init(parentFolder: VCSFolderResponse? = nil, itemsLocalNameAndPath: [LocalFileNameAndPath], jobFilesCallback: ( ([UploadJobLocalFile]) -> Void)? = nil, uploadCompletion: ( (Result<[VCSFileResponse], Error>) -> Void)? = nil) {
        self.itemsLocalNameAndPath = itemsLocalNameAndPath
        self.jobFilesCallback = jobFilesCallback
        self.uploadCompletion = uploadCompletion
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func loadHomeUserFolder() {
        guard let userHomeFolderURI = VCSUser.savedUser?.availableStorages.first?.folderURI else {
            self.folderResult = nil
            return
        }
        
        APIClient.folderAsset(assetURI: userHomeFolderURI).execute(completion: { (result: Result<VCSFolderResponse, Error>) in
            print("DONE loading - \(userHomeFolderURI)")
            switch result {
            case .success(let success):
                VCSCache.addToCache(item: success)
            case .failure(let failure):
                DDLogError("RootFolderLoadingView - loadModelTask - error: \(failure)")
            }
            self.folderResult = result
        })
    }
    
    public func areNamesValid(parentFolder: VCSFolderResponse) -> Bool {
        return itemsLocalNameAndPath.allSatisfy { FilenameValidator.isNameValid(ownerLogin: parentFolder.ownerLogin, storage: parentFolder.storageTypeString, prefix: parentFolder.prefix, name: $0.itemName) }
    }
    
    public func uploadAction(parentFolder: VCSFolderResponse, dismiss: DismissAction) {
        var jobFiles: [UploadJobLocalFile] = []
        
        itemsLocalNameAndPath.forEach { item in
            var relatedFiles: [UploadJobLocalFile] = []
            
            item.related.forEach {
                if let relatedForUpload = UploadJobLocalFile(ownerLogin: parentFolder.ownerLogin,
                                                            storageType: .INTERNAL,
                                                             prefix: parentFolder.storageTypeString.appendingPathComponent(parentFolder.prefix.appendingPathComponent($0.itemName.appendingPathExtension($0.itemPathExtension))),
                                                             tempFileURL: $0.itemURL,
                                                            related: [])
                {
                    relatedFiles.append(relatedForUpload)
                }
            }
            
            if let fileForUpload = UploadJobLocalFile(ownerLogin: parentFolder.ownerLogin,
                                                      storageType: parentFolder.storageType,
                                                      prefix: parentFolder.prefix.appendingPathComponent(item.itemName.appendingPathExtension(item.itemPathExtension)),
                                                      tempFileURL: item.itemURL,
                                                      related: relatedFiles)
            {
                jobFiles.append(fileForUpload)
                itemsUploading[item.itemURL] = fileForUpload.rID
            }
        }
        
        
        
        self.jobFilesCallback?(jobFiles)
        let job = UploadJob(localFiles: jobFiles, owner: parentFolder.ownerLogin, parentFolder: parentFolder)
        AssetUploader.shared.upload(uploadJob: job, multiFileCompletion: { (result: Result<[VCSFileResponse], Error>) in
            DispatchQueue.main.async {
                NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
                switch result {
                case .success(let successFile):
                    DDLogInfo("FileUploadViewModel - uploadAction - success upload: \(successFile)")
                case .failure(let failure):
                    DDLogError("FileUploadViewModel - uploadAction - error: \(failure)")
                }
                self.uploadCompletion?(result)
                dismiss()
            }
        })
        
        self.isUploading = true
        
        self.totalUnitCount = Double(jobFiles.count)
        jobFiles.forEach { (file: UploadJobLocalFile) in
            let uploadNotificationName = Notification.Name("uploading:\(file.rID)")
            NotificationCenter.default.addObserver(self, selector: #selector(self.handleUploadProgress(notification:)), name: uploadNotificationName, object: nil)
        }
    }
    
    @objc public func handleUploadProgress(notification: Notification) {
        guard let progress = notification.userInfo?["progress"] as? Double else { return }
        
        let fileID = notification.name.rawValue.replacingOccurrences(of: "uploading:", with: "")
        itemsUploadProgress[fileID] = progress
        
        if progress == ProgressValues.Finished.rawValue {
            self.completedUnitCount += 1
            
            if self.completedUnitCount == self.totalUnitCount {
                self.doneUploading = true
            }
        }
    }
}
