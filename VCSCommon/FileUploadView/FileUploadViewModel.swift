import SwiftUI
import CocoaLumberjackSwift

public class FileUploadViewModel: ObservableObject, Identifiable {
    
    public static var sharedModel: FileUploadViewModel = FileUploadViewModel()
    
    @Published public var isPresented: Bool = false
    @Published public var isFolderChooserPresented: Bool = false
    @Published public var parentFolder: VCSFolderResponse = VCSFolderResponse.nilFolder
    @Published public var itemsLocalNameAndPath: [LocalFileNameAndPath] = []
    
    @MainActor
    @discardableResult
    public func setupWithData(parentFolder: VCSFolderResponse, itemsLocalNameAndPath: [LocalFileNameAndPath]) -> FileUploadViewModel {
        self.isPresented = true
        self.parentFolder = parentFolder
        self.itemsLocalNameAndPath = itemsLocalNameAndPath
        
        return self
    }
    
    public func uploadAction() {
        //TODO: PDF uploaд
        defer { self.clearView() }
        
        var jobFiles: [UploadJobLocalFile] = []
        
        itemsLocalNameAndPath.forEach { item in
            var relatedFiles: [UploadJobLocalFile] = []
            if let thumbnailURL = item.thumbnailURL,
               let thumbnailForUpload = UploadJobLocalFile(ownerLogin: parentFolder.ownerLogin,
                                                           storageType: .INTERNAL,
                                                           prefix: parentFolder.prefix.appendingPathComponent(item.itemName.appendingPathExtension(VCSFileType.PNG.rawValue)),
                                                           tempFileURL: thumbnailURL,
                                                           related: [])
            {
                relatedFiles.append(thumbnailForUpload)
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