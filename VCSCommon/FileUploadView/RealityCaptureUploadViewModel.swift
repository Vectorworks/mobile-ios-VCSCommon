import SwiftUI
import CocoaLumberjackSwift

public enum ProjectsBrowseOptions: String, CaseIterable, Identifiable, CustomStringConvertible {
    public var id: String {
        return self.rawValue
    }
    
    public var description: String {
        return self.rawValue.vcsLocalized
    }
    
    case Simple
    case Custom
}

public class RealityCaptureUploadViewModel: RCFileUploadViewModel {
    @AppStorage(UploadViewConstants.lastSelectedRealityCaptureUploadFolderIDKey) public var lastSelectedFolderID: String = "nil" {
        didSet {
            DDLogInfo("FileUploadViewModel - lastSelectedFolderID - didSet: \(lastSelectedFolderID)")
            setSelectedFolderByID(lastSelectedFolderID)
        }
    }
    @Published public var rootFolderResult: Result<VCSFolderResponse, Error>?
    
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
        switch pickerProjectsBrowseOption {
        case .Simple:
            return selectedFolder?.prefix ?? newLocationNameFullPrefix
        case .Custom:
            return selectedFolder?.prefix ?? ""
        }
    }
    
    public var isSaveButtonDisabled: Bool {
        switch pickerProjectsBrowseOption {
        case .Simple:
            return nameErrors().isEmpty == false || isUploading == true || isNewLocationNameError() != nil || hasNewFolderTextFieldVisible
        case .Custom:
            return nameErrors().isEmpty == false || isUploading == true
        }
    }
    
    @Published public var newLocationName = ""
    @Published public var selectedFolder: VCSFolderResponse? {
        didSet {
            DDLogInfo("FileUploadViewModel - selectedFolder - didSet: \(selectedFolder?.rID ?? "nil")")
            if oldValue?.rID != selectedFolder?.rID {
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
    @Published public var hasNewFolderTextFieldVisible: Bool = false
    
    @Published public var pickerProjectsBrowseOption = ProjectsBrowseOptions.Simple
    
    func calculateTotalProgress() {
        var resultProgress = 0.0
        itemsUploading.values.forEach { key in
            let fileProgress = itemsUploadProgress[key] ?? 0
            resultProgress = resultProgress + fileProgress
        }
        
        totalProgress = resultProgress
    }
    
    public var warningViewPresention: ((any FileUploadViewModel) -> Void)? = nil
    public var jobFilesCallback: (([UploadJobLocalFile]) -> Void)? = nil
    public var uploadCompletion: ((Result<[VCSFileResponse], Error>) -> Void)? = nil
    
    public init(itemsLocalNameAndPath: [LocalFileNameAndPath], warningViewPresention: ((any FileUploadViewModel) -> Void)? = nil, jobFilesCallback: ( ([UploadJobLocalFile]) -> Void)? = nil, uploadCompletion: ( (Result<[VCSFileResponse], Error>) -> Void)? = nil) {
        self.itemsLocalNameAndPath = itemsLocalNameAndPath
        self.warningViewPresention = warningViewPresention
        self.jobFilesCallback = jobFilesCallback
        self.uploadCompletion = uploadCompletion
        self.baseFileName = itemsLocalNameAndPath.first?.itemName ?? ""
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func loadInitialRootFolder() {
        if let lastProjectFolder = VCSFolderResponse.realmStorage.getById(id: lastSelectedFolderID) {
            firstLoadFolder(folderAssetURI: lastProjectFolder.parent ?? lastProjectFolder.resourceURI)
        } else {
            loadRealityCaptureFolder()
        }
    }
    
    public func loadFolder(folderURI: String, folderResult: Binding<Result<VCSFolderResponse, Error>?>) {
        APIClient.folderAsset(assetURI: folderURI).execute(completion: { (result: Result<VCSFolderResponse, Error>) in
            switch result {
            case .success(let success):
                VCSCache.addToCache(item: success)
                if success.exists {
                    self.setSelectedFolderByID(self.lastSelectedFolderID)
                }
            case .failure(let failure):
                DDLogError("FileUploadViewModel - loadFolder(folderURI:) - error: \(failure)")
            }
            
            folderResult.wrappedValue = result
        })
    }
    
    func firstLoadFolder(folderAssetURI: String) {
        APIClient.folderAsset(assetURI: folderAssetURI).execute(completion: { (result: Result<VCSFolderResponse, Error>) in
            DDLogInfo("DONE loading - \(folderAssetURI)")
            var skipFolderResult = false
            switch result {
            case .success(let success):
                VCSCache.addToCache(item: success)
                if let lastProjectFolder = VCSFolderResponse.realmStorage.getById(id: self.lastSelectedFolderID), let subfolder = success.subfolders.first(where: { $0.rID == lastProjectFolder.rID }) {
                    if subfolder.exists {
                        self.setSelectedFolderByID(subfolder.rID)
                    }
                }
            case .failure(let failure):
                if failure.responseCode == VCSNetworkErrorCode.notFound.rawValue {
                    skipFolderResult = true
                    let storageValue = StorageType.S3
                    let userValue = VCSUser.savedUser?.login ?? ""
                    APIClient.createFolder(storage: storageValue, name: "Reality Capture", parentFolderPrefix: nil, owner: userValue).execute { (resultCreation: Result<VCSFolderResponse, Error>) in
                        switch resultCreation {
                        case .success(let success):
                            VCSCache.addToCache(item: success)
                            if success.exists {
                                self.setSelectedFolderByID(success.rID)
                            }
                        case .failure(let failure):
                            DDLogError("FileUploadViewModel - firstLoadFolder(folderAssetURI:) - createFolder - error: \(failure)")
                        }
                        self.rootFolderResult = resultCreation
                    }
                }
                DDLogError("FileUploadViewModel - firstLoadFolder(folderAssetURI:) - error: \(failure)")
            }
            if skipFolderResult == false {
                self.rootFolderResult = result
            }
        })
    }
    
    func loadRealityCaptureFolder() {
        guard let userHomeFolderURI = VCSUser.savedUser?.availableStorages.first?.folderURI else {
            self.rootFolderResult = nil
            return
        }
        
        firstLoadFolder(folderAssetURI: userHomeFolderURI.appendingPathComponent("p:Reality Capture").VCSNormalizedURLString())
    }
    
    public func loadHomeUserFolder() {
        guard let userHomeFolderURI = VCSUser.savedUser?.availableStorages.first?.folderURI else {
            self.rootFolderResult = nil
            return
        }
        
        firstLoadFolder(folderAssetURI: userHomeFolderURI)
    }
    
    public func loadProjectFolder() {
        guard let selectedFolderValue = selectedFolder else { return }
        APIClient.folderAsset(assetURI: selectedFolderValue.resourceURI).execute(completion: { (result: Result<VCSFolderResponse, Error>) in
            DDLogInfo("DONE loading - \(selectedFolderValue.resourceURI)")
            switch result {
            case .success(let success):
                VCSCache.addToCache(item: success)
                if success.exists {
                    self.setSelectedFolderByID(success.rID)
                }
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
    
    var newLocationNameFullPrefix: String {
        switch rootFolderResult {
        case .success(let success):
            guard success.subfolders.count == 0 else { return "" }
            guard let ownerLogin = VCSUser.savedUser?.login else { return "" }
            guard newLocationName.isEmpty == false else { return "" }
            
            let fullPrefix = success.prefix.appendingPathComponent(newLocationName)
            return fullPrefix
        case .failure(let failure):
            return ""
        case nil:
            return ""
        }
    }
    
    public func isNewLocationNameError() -> NameAndError? {
        switch rootFolderResult {
        case .success(let success):
            guard success.subfolders.count == 0 else { return nil }
            guard let ownerLogin = VCSUser.savedUser?.login else { return NameAndError(newLocationName, FilenameValidationError.invalidUser) }
            guard newLocationName.isEmpty == false else { return NameAndError(newLocationName, FilenameValidationError.empty) }
            
            let fullPrefix = success.prefix.appendingPathComponent(newLocationName)
            let result = FilenameValidator.nameError(ownerLogin: ownerLogin, storage: StorageType.S3.storageTypeString, prefix: fullPrefix)
            return result
        case .failure(let failure):
            return NameAndError(newLocationName, .invalidUser)
        case nil:
            return NameAndError(newLocationName, .invalidUser)
        }
    }
    
    public func nameErrors() -> [NameAndError] {
        guard baseFileName.isEmpty == false else { return [NameAndError(baseFileName, FilenameValidationError.empty)] }
        var counter = 0
        var allNamesErrors: [NameAndError] = []
        itemsLocalNameAndPath.forEach({ item in
            var name = generateNameForItem(baseName: baseFileName, counter: &counter)
            name = name.appendingPathExtension(item.itemPathExtension)
            if let nameError = nameError(namesToCheck: name) {
                allNamesErrors.append(nameError)
            }
        })
        
        return allNamesErrors
    }
    
    public func nameError(namesToCheck:String) -> NameAndError? {
        guard baseFileName.isEmpty == false else { return NameAndError(baseFileName, FilenameValidationError.empty) }
        
        guard var ownerLogin = VCSUser.savedUser?.login else { return NameAndError(baseFileName, FilenameValidationError.invalidUser) }
        var storageTypeString = StorageType.S3.storageTypeString
        var parentFolderPrefix = selectedFolderPrefix.isEmpty ? "" : "\(selectedFolderPrefix)/"
        if pickerProjectsBrowseOption == .Simple, let selectedFolder {
            ownerLogin = selectedFolder.ownerLogin
            storageTypeString = selectedFolder.storageTypeString
            parentFolderPrefix = selectedFolder.prefix
        }
        
        let fullPrefix = parentFolderPrefix.appendingPathComponent(namesToCheck)
        let result = FilenameValidator.nameError(ownerLogin: ownerLogin, storage: storageTypeString, prefix: fullPrefix)
        
        return result
    }
    
    public func renameItemsBeforeSave() {
        var counter = 0
        itemsLocalNameAndPath.forEach { item in
            let name = generateNameForItem(baseName: baseFileName, counter: &counter)
            item.itemName = name
        }
    }
    
    public func uploadAction(dismiss: DismissAction) {
        var jobFiles: [UploadJobLocalFile] = []
        
        self.renameItemsBeforeSave()
        
        guard var ownerLogin = VCSUser.savedUser?.login else { return }
        var storageTypeString = StorageType.S3.storageTypeString
        var storageType = StorageType.S3
        var parentFolderPrefix = selectedFolderPrefix
        if pickerProjectsBrowseOption == .Custom, let selectedFolder {
            ownerLogin = selectedFolder.ownerLogin
            storageTypeString = selectedFolder.storageTypeString
            storageType = selectedFolder.storageType
            parentFolderPrefix = selectedFolder.prefix
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
        
        let job = UploadJob(localFiles: jobFiles, owner: ownerLogin, parentFolder: nil)
        AssetUploader.shared.upload(uploadJob: job, multiFileCompletion: { [weak self] (result: Result<[VCSFileResponse], Error>) in
            DispatchQueue.main.async { [weak self] in
                NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
                switch result {
                case .success(let successFiles):
                    DDLogInfo("FileUploadViewModel - uploadAction - success upload: \(successFiles)")
                    if let successFile = successFiles.first {
                        self?.selectedFolder?.appendFile(successFile)
                    }
                case .failure(let failure):
                    DDLogError("FileUploadViewModel - uploadAction - error: \(failure)")
                }
                self?.uploadCompletion?(result)
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
