import Foundation
import CocoaLumberjackSwift

class UpdateLocalFileOperation: AsyncOperation {
    let localFile: UploadJobLocalFile
    var fileResponse: VCSFileResponse?
    
    var result: Result<VCSFileResponse, Error> = .failure(VCSError.OperationNotExecuted)
    
    init(localFile: UploadJobLocalFile, fileResponse: VCSFileResponse?) {
        self.localFile = localFile
        self.fileResponse = fileResponse
        
        super.init()
        self.name = self.localFile.rID
    }
    
    override func main() {
        guard let fileResponse else {
            DDLogInfo("Skipping UpdateLocalFileOperation")
            self.localFile.uploadingState = .Error
            VCSCache.addToCache(item: self.localFile)
            self.state = .finished
            return
        }
        
        DDLogInfo("Executing UpdateLocalFileOperation")
        DDLogVerbose("Executing \(String(describing: self)) - with params: operationID: \(self.localFile.name), fileResponse: \(fileResponse.name)")
        
        DDLogInfo("SF owner - \(fileResponse.ownerLogin), storage - \(fileResponse.storageTypeString), prefix - \(fileResponse.prefix)")
        DDLogInfo("LF owner - \(self.localFile.ownerLogin), storage - \(self.localFile.storageTypeString), prefix - \(self.localFile.prefix)")
        AssetUploader.updateUploadedFile(fileResponse, withLocalFileForUnuploadedFile: self.localFile)
        
        VCSCache.addToCache(item: fileResponse)
        if let parentFolderID = self.localFile.parentUploadJob?.parentFolder?.rID {
            //Work with the Database to exclude ram caching bugs
            VCSGenericRealmModelStorage<VCSFolderResponse.RealmModel>().getById(id: parentFolderID)?.appendFile(fileResponse)
        }
        
        DDLogInfo("Successfully uploaded \(self.localFile.name) and its related")
        NotificationCenter.postNotification(name: Notification.Name("VCSUpdateLocalDataSources"), userInfo: ["file" : localFile])
        
        self.result = .success(fileResponse)
        
        self.localFile.uploadingState = .Done
        VCSCache.addToCache(item: self.localFile)
        self.localFile.parentUploadJob?.reCheckState(localFile: self.localFile)
        
        self.state = .finished
    }
}
