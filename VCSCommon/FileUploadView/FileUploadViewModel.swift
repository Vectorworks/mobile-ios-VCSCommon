import SwiftUI
import CocoaLumberjackSwift

public enum ProjectsBrowseOptions: String, CaseIterable, Identifiable, CustomStringConvertible {
    public var id: String {
        return self.rawValue
    }
    
    public var description: String {
        return self.rawValue.vcsLocalized
    }
    
    case New
    case Existing
}

public class FileUploadViewModel: ObservableObject {
    @Published public var rootFolderResult: Result<VCSFolderResponse, Error>?
    public var projectFolderID: Binding<String?> {
        Binding(
            get: { return self.projectFolder?.rID },
            set: { value in
                switch self.rootFolderResult {
                case .success(let success):
                    self.projectFolder = success.subfolders.first(where: {
                        $0.rID == value
                    })
                case .failure(_):
                    self.projectFolder = nil
                case nil:
                    self.projectFolder = nil
                }
            }
          )
    }
    @Published public var projectFolder: VCSFolderResponse?
    {
        didSet {
            if oldValue?.rID != projectFolder?.rID {
                loadProjectFolder()
            }
        }
    }
    @Published public var itemsLocalNameAndPath: [LocalFileNameAndPath]
    @Published public var itemsUploading: [URL: String] = [:]
    @Published public var itemsUploadProgress: [String: Double] = [:]
    @Published public var isUploading = false
    @Published public var totalUploadsCount = 0.0
    @Published public var totalProgress: Double = 0.0
    @Published public var baseFileName: String
    
    @Published public var pickerProjectsBrowseOption = ProjectsBrowseOptions.New
    
    func calculateTotalProgress() {
        var resultProgress = 0.0
        itemsUploading.values.forEach { key in
            let fileProgress = itemsUploadProgress[key] ?? 0
            resultProgress = resultProgress + fileProgress
        }
        
        totalProgress = resultProgress
    }
    
    public var jobFilesCallback: (([UploadJobLocalFile]) -> Void)? = nil
    public var uploadCompletion: ((Result<[VCSFileResponse], Error>) -> Void)? = nil
    
    public init(itemsLocalNameAndPath: [LocalFileNameAndPath], jobFilesCallback: ( ([UploadJobLocalFile]) -> Void)? = nil, uploadCompletion: ( (Result<[VCSFileResponse], Error>) -> Void)? = nil) {
        self.itemsLocalNameAndPath = itemsLocalNameAndPath
        self.jobFilesCallback = jobFilesCallback
        self.uploadCompletion = uploadCompletion
        self.baseFileName = itemsLocalNameAndPath.first?.itemName ?? ""
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func loadHomeUserFolder() {
        guard let userHomeFolderURI = VCSUser.savedUser?.availableStorages.first?.folderURI else {
            self.rootFolderResult = nil
            return
        }
        
        APIClient.folderAsset(assetURI: userHomeFolderURI).execute(completion: { (result: Result<VCSFolderResponse, Error>) in
            DDLogInfo("DONE loading - \(userHomeFolderURI)")
            switch result {
            case .success(let success):
                VCSCache.addToCache(item: success)
                if let subfolder = success.subfolders.first {
                    self.projectFolder = subfolder
                } else {
                    self.projectFolder = success
                }
                self.pickerProjectsBrowseOption = .New
            case .failure(let failure):
                DDLogError("FileUploadViewModel - loadHomeUserFolder - error: \(failure)")
            }
            self.rootFolderResult = result
        })
    }
    
    public func loadProjectFolder() {
        guard let projectFolderValue = projectFolder else { return }
        APIClient.folderAsset(assetURI: projectFolderValue.resourceURI).execute(completion: { (result: Result<VCSFolderResponse, Error>) in
            DDLogInfo("DONE loading - \(projectFolderValue.resourceURI)")
            switch result {
            case .success(let success):
                VCSCache.addToCache(item: success)
                self.projectFolder = success
            case .failure(let failure):
                DDLogError("FileUploadViewModel - loadProjectFolder - error: \(failure)")
            }
        })
    }
    
    func generateNameForItem(baseName: String, counter: inout Int) -> String {
        var name = baseFileName
        if counter != 0 {
            name = name + "_\(counter)"
        }
        counter = counter + 1
        return name
    }
    
    public func areNamesValid(newProjectName: String) -> Set<Result<String, FilenameValidationError>> {
        guard baseFileName.isEmpty == false else { return [.failure(FilenameValidationError.empty)] }
        var counter = 0
        var allSatisfySet: Set<Result<String, FilenameValidationError>> = []
        itemsLocalNameAndPath.forEach({ item in
            var name = generateNameForItem(baseName: baseFileName, counter: &counter)
            name = name.appendingPathExtension(item.itemPathExtension)
            allSatisfySet.insert(isNamesValid(namesToCheck: name, newProjectName: newProjectName))
        })
        
        return allSatisfySet
    }
    
    public func isNamesValid(namesToCheck:String, newProjectName: String) -> Result<String, FilenameValidationError> {
        guard baseFileName.isEmpty == false else { return .failure(.empty) }
        
        guard var ownerLogin = VCSUser.savedUser?.login else { return .failure(.empty) }
        var storageTypeString = StorageType.S3.storageTypeString
        var parentFolderPrefix = newProjectName.isEmpty ? "" : "\(newProjectName)/"
        if pickerProjectsBrowseOption == .Existing, let parentFolder = projectFolder {
            ownerLogin = parentFolder.ownerLogin
            storageTypeString = parentFolder.storageTypeString
            parentFolderPrefix = parentFolder.prefix
        }
        
        let fullPrefix = parentFolderPrefix.appendingPathComponent(namesToCheck)
        let result = FilenameValidator.validateFilename(ownerLogin: ownerLogin, storage: storageTypeString, prefix: fullPrefix)
        
        return result
    }
    
    public func renameItemsBeforeSave() {
        var counter = 0
        itemsLocalNameAndPath.forEach { item in
            let name = generateNameForItem(baseName: baseFileName, counter: &counter)
            item.itemName = name
        }
    }
    
    public func uploadAction(newProjectName: String, dismiss: DismissAction) {
        var jobFiles: [UploadJobLocalFile] = []
        
        self.renameItemsBeforeSave()
        
        guard var ownerLogin = VCSUser.savedUser?.login else { return }
        var storageTypeString = StorageType.S3.storageTypeString
        var storageType = StorageType.S3
        var parentFolderPrefix = "\(newProjectName)/"
        if pickerProjectsBrowseOption == .Existing, let parentFolder = projectFolder {
            ownerLogin = parentFolder.ownerLogin
            storageTypeString = parentFolder.storageTypeString
            storageType = parentFolder.storageType
            parentFolderPrefix = parentFolder.prefix
        }
        
        itemsLocalNameAndPath.forEach { item in
            var relatedFiles: [UploadJobLocalFile] = []
            
            item.related.forEach {
                if let relatedForUpload = UploadJobLocalFile(ownerLogin: ownerLogin,
                                                            storageType: .INTERNAL,
                                                             prefix: storageTypeString.appendingPathComponent(parentFolderPrefix.appendingPathComponent($0.itemName.appendingPathExtension($0.itemPathExtension))),
                                                             tempFileURL: $0.itemURL,
                                                            related: [])
                {
                    relatedFiles.append(relatedForUpload)
                }
            }
            
            if let fileForUpload = UploadJobLocalFile(ownerLogin: ownerLogin,
                                                      storageType: storageType,
                                                      prefix: parentFolderPrefix.appendingPathComponent(item.itemName.appendingPathExtension(item.itemPathExtension)),
                                                      tempFileURL: item.itemURL,
                                                      related: relatedFiles)
            {
                jobFiles.append(fileForUpload)
                itemsUploading[item.itemURL] = fileForUpload.rID
            }
        }
        
        
        
        self.jobFilesCallback?(jobFiles)
        let job = UploadJob(localFiles: jobFiles, owner: ownerLogin, parentFolder: projectFolder)
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
