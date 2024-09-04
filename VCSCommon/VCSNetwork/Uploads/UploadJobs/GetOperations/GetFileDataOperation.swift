import Foundation
import CocoaLumberjackSwift

class GetFileDataOperation: AsyncOperation {
    var file: VCSFileResponse
    
    var result: Result<VCSFileResponse, Error> = .failure(VCSError.OperationNotExecuted("GetUploadedFileDataOperation"))
    
    init(file: VCSFileResponse) {
        self.file = file
        
        super.init()
        self.name = self.file.rID
    }
    
    override func main() {
        DDLogInfo("Executing GetFileDataOperation")
        DDLogVerbose("Executing \(String(describing: self)) - with params: operationID: \(self.file.name), owner: \(self.file.ownerLogin), storage: \(self.file.storageTypeString), filePrefix: \(self.file.prefix)")
        
        APIClient.fileInfo(rID: file.rID).execute { (result: Result<VCSFileResponse, Error>) in
            self.result = result
            self.state = .finished
        }
    }
}
