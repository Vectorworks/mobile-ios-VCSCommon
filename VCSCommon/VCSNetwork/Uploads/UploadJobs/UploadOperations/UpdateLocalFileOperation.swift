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
            self.localFile.addToCache()
            self.state = .finished
            return
        }
        
        DDLogInfo("Executing UpdateLocalFileOperation")
        DDLogVerbose("Executing \(String(describing: self)) - with params: operationID: \(self.localFile.name), fileResponse: \(fileResponse.name)")
        
        DDLogInfo("SF owner - \(fileResponse.ownerLogin), storage - \(fileResponse.storageTypeString), prefix - \(fileResponse.prefix)")
        DDLogInfo("LF owner - \(self.localFile.ownerLogin), storage - \(self.localFile.storageTypeString), prefix - \(self.localFile.prefix)")
        AssetUploader.updateUploadedFile(fileResponse, withLocalFileForUnuploadedFile: self.localFile)
        
        VCSCache.addToCache(item: fileResponse)
        
        DDLogInfo("Successfully uploaded \(self.localFile.name) and its related")
        NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
        
        self.result = .success(fileResponse)
        
        self.localFile.uploadingState = .Done
        self.localFile.addToCache()
        self.localFile.parentUploadJob?.reCheckState()
        
        self.state = .finished
    }
}
