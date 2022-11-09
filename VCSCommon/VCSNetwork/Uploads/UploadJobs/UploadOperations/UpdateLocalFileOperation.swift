import Foundation
import CocoaLumberjackSwift

class UpdateLocalFileOperation: AsyncOperation {
    let localFile: UploadJobLocalFile
    var fileResponse: VCSFileResponse?
    let filesApp: Bool
    
    var result: Result<VCSFileResponse, Error> = .failure(VCSError.OperationNotExecuted)
    
    init(localFile: UploadJobLocalFile, fileResponse: VCSFileResponse?, filesApp: Bool = false) {
        self.localFile = localFile
        self.fileResponse = fileResponse
        
        self.filesApp = filesApp
        
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
        
        if filesApp == false {
            DDLogInfo("SF owner - \(fileResponse.ownerLogin), storage - \(fileResponse.storageTypeString), prefix - \(fileResponse.prefix)")
            DDLogInfo("LF owner - \(self.localFile.ownerLogin), storage - \(self.localFile.storageTypeString), prefix - \(self.localFile.prefix)")
            AssetUploader.updateUploadedFile(fileResponse, withLocalFileForUnuploadedFile: self.localFile)
        }
        VCSCache.addToCache(item: fileResponse)
        if filesApp == false {
            #warning("Remove only from uploads list")
//            UnuploadedFileActions.deleteUnuploadedFiles([self.localFile])
        }
        
        AssetUploader.removeUploadedFileFromAPIClient(self.localFile)
        DDLogInfo("Successfully uploaded \(self.localFile.name) and its related")
        NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil)
        
        self.result = .success(fileResponse)
        
        self.localFile.uploadingState = .Done
        self.localFile.addToCache()
        self.localFile.parentUploadJob?.reCheckState()
        
        self.state = .finished
    }
}
