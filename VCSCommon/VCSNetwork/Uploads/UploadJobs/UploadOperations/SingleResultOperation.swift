import Foundation
import CocoaLumberjackSwift

class SingleResultOperation: AsyncOperation {
    var completion: ((Result<VCSFileResponse, Error>) -> Void)?
    var result: Result<VCSFileResponse, Error> = .failure(VCSError.OperationNotExecuted)
    
    init(operationID: String, completion: ((Result<VCSFileResponse, Error>) -> Void)? = nil) {
        self.completion = completion

        super.init()
        self.name = operationID
    }
    
    override func main() {
        DDLogInfo("Executing SingleResultOperation")
        
        self.completion?(result)
        
        self.state = .finished
    }
}

class ArrayResultOperation: AsyncOperation {
    var completion: ((Result<[VCSFileResponse], Error>) -> Void)?
    var result: Result<[VCSFileResponse], Error> = .success([])
    
    init(operationID: String, completion: ((Result<[VCSFileResponse], Error>) -> Void)? = nil) {
        self.completion = completion

        super.init()
        self.name = operationID
    }
    
    override func main() {
        DDLogInfo("Executing ArrayResultOperation")
        
        self.completion?(result)
        
        self.state = .finished
    }
}
