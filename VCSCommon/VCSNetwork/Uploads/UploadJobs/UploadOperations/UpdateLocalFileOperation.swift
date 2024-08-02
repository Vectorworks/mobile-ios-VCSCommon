import Foundation
import CocoaLumberjackSwift

class UpdateLocalFileOperation: AsyncOperation {
    let localFile: UploadJobLocalFile
    var fileResponse: VCSFileResponse?
    
    var result: Result<VCSFileResponse, Error> = .failure(VCSError.OperationNotExecuted("UpdateLocalFileOperation"))
    
    init(localFile: UploadJobLocalFile, fileResponse: VCSFileResponse?) {
        self.localFile = localFile
        self.fileResponse = fileResponse
        
        super.init()
        self.name = self.localFile.rID
    }
    
    override func main() {
        guard let fileResponse else {
            DDLogInfo("Skipping UpdateLocalFileOperation - \(localFile.name)")
            self.localFile.uploadingState = .Error
            self.localFile.addToCache()
            self.state = .finished
            return
        }
        
        DDLogInfo("Executing UpdateLocalFileOperation")
        DDLogVerbose("Executing \(String(describing: self)) - with params: operationID: \(self.localFile.name), fileResponse: \(fileResponse.name)")
        
        DDLogInfo("SF owner - \(fileResponse.ownerLogin), storage - \(fileResponse.storageTypeString), prefix - \(fileResponse.prefix)")
        DDLogInfo("LF owner - \(self.localFile.ownerLogin), storage - \(self.localFile.storageTypeString), prefix - \(self.localFile.prefix)")
        AssetUploader.updateUploadedFile(fileResponse, withLocalFileForUnuploadedFile: self.localFile)
        
        fileResponse.addToCache()
        if let parentFolderID = self.localFile.parentUploadJob?.parentFolder?.rID {
            //Work with the Database to exclude ram caching bugs
            //TODO: REALM_CHANGE
//            VCSGenericRealmModelStorage<VCSFolderResponse.RealmModel>().getById(id: parentFolderID)?.appendFile(fileResponse)
        }
        
        DDLogInfo("Successfully uploaded \(self.localFile.name) and its related")
        NotificationCenter.postNotification(name: Notification.Name("VCSUpdateLocalDataSources"), userInfo: ["file" : localFile])
        
        self.result = .success(fileResponse)
        
        self.localFile.uploadingState = .Done
        self.localFile.addToCache()
        self.localFile.parentUploadJob?.reCheckState(localFile: self.localFile)
        
        self.state = .finished
    }
}
