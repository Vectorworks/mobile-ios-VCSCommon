import SwiftUI
import CocoaLumberjackSwift

public class FileUploadViewModel: ObservableObject, Identifiable {
    
    public static var sharedModel: FileUploadViewModel = FileUploadViewModel()
    
    @Published public var isPresented: Bool = false
    @Published public var isFolderChooserPresented: Bool = false
    @Published public var parentFolder: VCSFolderResponse = VCSFolderResponse.nilFolder
    @Published public var itemsLocalNameAndPath: [LocalFileNameAndPath] = []
    @Published public var jobFilesCallback: (([UploadJobLocalFile]) -> Void)? = nil
    @Published public var uploadCompletion: ((Result<[VCSFileResponse], Error>) -> Void)? = nil
    
    @MainActor
    @discardableResult
    public func setupWithData(parentFolder: VCSFolderResponse, itemsLocalNameAndPath: [LocalFileNameAndPath], jobFilesCallback: (([UploadJobLocalFile]) -> Void)? = nil, uploadCompletion: ((Result<[VCSFileResponse], Error>) -> Void)? = nil) -> FileUploadViewModel {
        self.isPresented = true
        self.parentFolder = parentFolder
        self.itemsLocalNameAndPath = itemsLocalNameAndPath
        self.jobFilesCallback = jobFilesCallback
        self.uploadCompletion = uploadCompletion
        
        return self
    }
    
    public func uploadAction() {
        defer { self.clearView() }
        
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
            }
        }
        
        
        
        self.jobFilesCallback?(jobFiles)
        let job = UploadJob(localFiles: jobFiles, owner: parentFolder.ownerLogin, parentFolder: parentFolder)
        AssetUploader.shared.upload(uploadJob: job, multiFileCompletion:  { (result: Result<[VCSFileResponse], Error>) in
            DispatchQueue.main.async {
                NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
                switch result {
                case .success(let successFile):
                    DDLogInfo("FileUploadViewModel - uploadAction - success upload: \(successFile)")
                case .failure(let failure):
                    DDLogError("FileUploadViewModel - uploadAction - error: \(failure)")
                }
                self.uploadCompletion?(result)
            }
        })
    }
    
    public func cancelAction() {
        self.clearView()
    }
    
    private func clearView() {
        self.isPresented = false
        self.parentFolder = VCSFolderResponse.nilFolder
        self.itemsLocalNameAndPath = []
    }
}
