import Foundation
import CocoaLumberjackSwift

class GetUploadedFileDataOperation: AsyncOperation {
    var uploadResponseResult: VCSUploadDataResponse?
    var localFile: UploadJobLocalFile
    
    var result: Result<VCSFileResponse, Error> = .failure(VCSError.OperationNotExecuted)
    
    init(localFile: UploadJobLocalFile) {
        self.localFile = localFile
        
        super.init()
        self.name = self.localFile.rID
    }
    
    override func main() {
        guard let uploadResponse = self.uploadResponseResult else {
            DDLogInfo("Skipping GetUplaodedFileDataOperation")
            self.localFile.uploadingState = .Error
            VCSCache.addToCache(item: self.localFile)
            self.state = .finished
            return
        }
        
        DDLogInfo("Executing GetUplaodedFileDataOperation")
        DDLogVerbose("Executing \(String(describing: self)) - with params: operationID: \(self.localFile.name), owner: \(self.localFile.ownerLogin), storage: \(self.localFile.storageTypeString), filePrefix: \(self.localFile.prefix)")
        
        APIClient.fileData(owner: self.localFile.ownerLogin, storage: self.localFile.storageTypeString, filePrefix: self.localFile.prefix, updateFromStorage: true, googleDriveID: uploadResponse.googleDriveID, googleDriveVerID: uploadResponse.googleDriveVerID).execute { (result: Result<VCSFileResponse, Error>) in
            self.result = result
            self.state = .finished
        }
    }
}
