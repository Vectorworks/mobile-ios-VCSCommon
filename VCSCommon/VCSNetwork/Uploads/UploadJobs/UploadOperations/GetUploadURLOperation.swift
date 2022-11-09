import Foundation
import CocoaLumberjackSwift

class GetUploadURLOperation: AsyncOperation {
    static let defaultFailureError = VCSError.OperationNotExecuted
    
    var localFile: UploadJobLocalFile
    
    var result: Result<VCSUploadURL, Error> = .failure(GetUploadURLOperation.defaultFailureError)
    
    init(localFile: UploadJobLocalFile) {
        self.localFile = localFile
        
        super.init()
        self.name = self.localFile.rID
    }
    
    override func main() {
        DDLogInfo("Executing GetUploadURLOperation")
        DDLogVerbose("Executing \(String(describing: self)) - with params: operationID: \(self.localFile.name), owner: \(self.localFile.ownerLogin), storage: \(self.localFile.storageTypeString), filePrefix: \(self.localFile.prefix), size: \(self.localFile.size)")
        
        self.localFile.uploadingState = .Waiting
        self.localFile.addToCache()
        APIClient.getUploadURL(owner: self.localFile.ownerLogin, storage: self.localFile.storageTypeString, filePrefix: self.localFile.prefix, size: self.localFile.sizeAsInt).execute(completion: { (result: Result<VCSUploadURL, Error>) in
            self.result = result
            self.state = .finished
        })
    }
}
