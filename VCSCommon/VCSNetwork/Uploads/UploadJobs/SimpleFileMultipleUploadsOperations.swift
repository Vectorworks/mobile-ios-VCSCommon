import Foundation

public class SimpleFileMultipleUploadsOperations: OperationsGenerator {
    public init() {}
    
    var operations: [Operation] = []
    
    func getOperations(localFile: UploadJobLocalFile, completion: ((Result<VCSFileResponse, Error>) -> Void)? = nil) -> [Operation] {
        self.operations.removeAll()
        return self.operations
    }
    
    public func getOperations(localFiles: [UploadJobLocalFile], completion: ((Result<[VCSFileResponse], Error>) -> Void)? = nil) -> [Operation] {
        self.operations.removeAll()
        guard localFiles.count > 0 else { return self.operations }
        
        var lastUpdateLocalFileOperations: [UpdateLocalFileOperation] = []
        localFiles.forEach({
            let operations = SimpleFileUploadOperations().getOperations(localFile:$0)
            if let updateLocalFileOperation = operations.last as? UpdateLocalFileOperation {
                lastUpdateLocalFileOperations.append(updateLocalFileOperation)
            }
            self.operations.append(contentsOf: operations)
        })
        
        OperationsUtils.appendFinalOperation(operations: &self.operations, lastUploadOperations: lastUpdateLocalFileOperations, operationID: localFiles.last?.rID ?? UUID().uuidString, completion: completion)
        
        return self.operations
    }
}
