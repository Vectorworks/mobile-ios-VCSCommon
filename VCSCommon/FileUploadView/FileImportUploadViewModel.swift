import SwiftUI
import CocoaLumberjackSwift

public class FileImportUploadViewModel: FileUploadViewModel {
    @AppStorage(UploadViewConstants.lastSelectedImportUploadFolderIDKey) public var lastSelectedFolderID: String = "nil" {
        didSet {
            DDLogInfo("FileImportUploadViewModel - lastSelectedFolderID - didSet: \(lastSelectedFolderID)")
            setSelectedFolderByID(lastSelectedFolderID)
        }
    }
    
    @Published public var selectedFolder: VCSFolderResponse? {
        didSet {
            DDLogInfo("FileUploadViewModel - selectedFolder - didSet: \(selectedFolder?.rID ?? "nil")")
            if oldValue?.rID != selectedFolder?.rID {
                loadFolder(folderURI: selectedFolder?.resourceURI ?? "", folderResult: .constant(nil))
            }
        }
    }
    
    @Published public var isUploading: Bool = false
    @Published public var totalProgress: Double = 0.0
    @Published public var totalUploadsCount: Double = 0.0
    
    @Published public var itemsLocalNameAndPath: [LocalFileNameAndPath] = []
    
    @Published public var rootFolderResult: Result<VCSFolderResponse, any Error>?


    var itemsUploading: [URL: String] = [:]
    var itemsUploadProgress: [String: Double] = [:]
    
    public var jobFilesCallback: (([UploadJobLocalFile]) -> Void)? = nil
    public var uploadCompletion: ((Result<[VCSFileResponse], Error>) -> Void)? = nil
    
    public init(itemsLocalNameAndPath: [LocalFileNameAndPath], jobFilesCallback: ( ([UploadJobLocalFile]) -> Void)? = nil, uploadCompletion: ( (Result<[VCSFileResponse], Error>) -> Void)? = nil) {
        self.itemsLocalNameAndPath = itemsLocalNameAndPath
        self.jobFilesCallback = jobFilesCallback
        self.uploadCompletion = uploadCompletion
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setSelectedFolderByID(_ id: String) {
        switch self.rootFolderResult {
        case .success(let success):
            self.selectedFolder = VCSFolderResponse.realmStorage.getById(id: id)
        case .failure(_):
            self.selectedFolder = nil
        case nil:
            self.selectedFolder = nil
        }
    }
    
    public var selectedFolderPrefix: String {
        return selectedFolder?.prefix ?? ""
    }
    
    func calculateTotalProgress() {
        var resultProgress = 0.0
        itemsUploading.values.forEach { key in
            let fileProgress = itemsUploadProgress[key] ?? 0
            resultProgress = resultProgress + fileProgress
        }
        
        totalProgress = resultProgress
    }
    
    
    public func loadFolder(folderURI: String, folderResult: Binding<Result<VCSFolderResponse, Error>?>) {
        guard folderURI.isEmpty == false else {
            DDLogError("SingleFileUploadViewModel - loadFolder(folderURI:) - error: folderURI.isEmpty")
            return
        }
        
        APIClient.folderAsset(assetURI: folderURI).execute(completion: { (result: Result<VCSFolderResponse, Error>) in
            folderResult.wrappedValue = result
            
            switch result {
            case .success(let success):
                VCSCache.addToCache(item: success)
                self.setSelectedFolderByID(self.lastSelectedFolderID)
            case .failure(let failure):
                DDLogError("SingleFileUploadViewModel - loadFolder(folderURI:) - error: \(failure)")
            }
        })
    }
    
    public func nameErrors() -> [NameAndError] {
        guard let item = itemsLocalNameAndPath.first else { return [NameAndError("", .empty)] }
        var result: [NameAndError] = itemsLocalNameAndPath.compactMap({ (item: LocalFileNameAndPath) in
            var name = item.itemName
            name = name.appendingPathExtension(item.itemPathExtension)
            return nameError(namesToCheck: name)
        })
        
        return result
    }
    
    public func nameError(namesToCheck:String) -> NameAndError? {
        guard let selectedFolder = selectedFolder else { return NameAndError(namesToCheck, .invalidUser) }
        
        let ownerLogin = selectedFolder.ownerLogin
        let storageTypeString = selectedFolder.storageTypeString
        let parentFolderPrefix = selectedFolder.prefix
        
        let fullPrefix = parentFolderPrefix.appendingPathComponent(namesToCheck)
        let result = FilenameValidator.nameError(ownerLogin: ownerLogin, storage: storageTypeString, prefix: fullPrefix)
        
        return result
    }
    
    public func uploadAction(dismiss: DismissAction) {
        guard let uploadParams = FileUploadURLParams(folder: selectedFolder) else { return }
        var jobFiles: [UploadJobLocalFile] = []
        
        let filesWithInvalidCharacters = filesHasInvalidName.compactMap(\.name)
        var filteredLocalFilesToUpload: [LocalFileNameAndPath] = itemsLocalNameAndPath
        if filesWithInvalidCharacters.count > 0 {
            filteredLocalFilesToUpload = itemsLocalNameAndPath.filter({ (localFile: LocalFileNameAndPath) in
                filesWithInvalidCharacters.contains(localFile.itemName) == false
            })
        }
        
        filteredLocalFilesToUpload.forEach { item in
            var relatedFiles: [UploadJobLocalFile] = []
            
            item.related.forEach {
                if let relatedForUpload = UploadJobLocalFile(ownerLogin: uploadParams.ownerLogin,
                                                            storageType: .INTERNAL,
                                                             prefix: uploadParams.storageTypeString.appendingPathComponent(uploadParams.parentFolderPrefix.appendingPathComponent($0.itemName.appendingPathExtension($0.itemPathExtension))),
                                                             tempFileURL: $0.itemURL,
                                                            related: [])
                {
                    relatedFiles.append(relatedForUpload)
                }
            }
            
            if let fileForUpload = UploadJobLocalFile(ownerLogin: uploadParams.ownerLogin,
                                                      storageType: uploadParams.storageType,
                                                      prefix: uploadParams.parentFolderPrefix.appendingPathComponent(item.itemName.appendingPathExtension(item.itemPathExtension)),
                                                      tempFileURL: item.itemURL,
                                                      related: relatedFiles)
            {
                jobFiles.append(fileForUpload)
                itemsUploading[item.itemURL] = fileForUpload.rID
            }
        }
        
        
        
        self.jobFilesCallback?(jobFiles)
        let job = UploadJob(localFiles: jobFiles, owner: uploadParams.ownerLogin, parentFolder: nil)
        AssetUploader.shared.upload(uploadJob: job, multiFileCompletion: { [unowned self] (result: Result<[VCSFileResponse], Error>) in
            DispatchQueue.main.async {
                NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
                switch result {
                case .success(let successFiles):
                    DDLogInfo("FileUploadViewModel - uploadAction - success upload: \(successFiles)")
                    if let successFile = successFiles.first {
                        self.selectedFolder?.appendFile(successFile)
                    }
                case .failure(let failure):
                    DDLogError("FileUploadViewModel - uploadAction - error: \(failure)")
                }
                self.uploadCompletion?(result)
                dismiss()
            }
        })
        
        self.isUploading = true
        
        self.totalUploadsCount = Double(jobFiles.count)
        jobFiles.forEach { (file: UploadJobLocalFile) in
            let uploadNotificationName = Notification.Name("uploading:\(file.rID)")
            NotificationCenter.default.addObserver(self, selector: #selector(self.handleUploadProgress(notification:)), name: uploadNotificationName, object: nil)
        }
    }
    
    @objc public func handleUploadProgress(notification: Notification) {
        guard let progress = notification.userInfo?["progress"] as? Double else { return }
        
        let fileID = notification.name.rawValue.replacingOccurrences(of: "uploading:", with: "")
        
        if progress == ProgressValues.Finished.rawValue {
            itemsUploadProgress[fileID] = 1
        } else if progress == ProgressValues.Started.rawValue {
            itemsUploadProgress[fileID] = 0
        } else {
            itemsUploadProgress[fileID] = progress
        }
        
        calculateTotalProgress()
    }
}
