import Foundation

protocol OperationsGenerator {
    func getOperations(localFile: UploadJobLocalFile, completion: ((Result<VCSFileResponse, Error>) -> Void)?) -> [Operation]
}

precedencegroup OperationChaining {
    associativity: left
}
infix operator ==> : OperationChaining

@discardableResult
func ==><T: Operation>(lhs: T, rhs: T) -> T {
    rhs.addDependency(lhs)
    return rhs
}

public class OperationsUtils {
    static func appendFinalOperation(operations: inout [Operation], lastUploadOperation: UpdateLocalFileOperation, operationID: String, completion: ((Result<VCSFileResponse, Error>) -> Void)? = nil) {
        guard let finalOpr = completion else { return }
        
        let resultOpr = SingleResultOperation(operationID: operationID, completion: finalOpr)
        let adapterResultOpr = BlockOperation(block: {
            resultOpr.result = lastUploadOperation.result
        })
        
        adapterResultOpr.addDependency(lastUploadOperation)
        resultOpr.addDependency(adapterResultOpr)
        
        operations.append(adapterResultOpr)
        operations.append(resultOpr)
    }
    
    static func appendFinalOperation(operations: inout [Operation], lastUploadOperations: [UpdateLocalFileOperation], operationID: String, completion: ((Result<[VCSFileResponse], Error>) -> Void)? = nil) {
        guard let finalOpr = completion else { return }
        
        let resultOpr = ArrayResultOperation(operationID: operationID, completion: finalOpr)
        lastUploadOperations.forEach { opearation in
            let adapterResultOpr = BlockOperation(block: {
                switch opearation.result {
                case .success(let fileResponse):
                    do {
                        let prevResult = try resultOpr.result.get()
                        var resultArray = [fileResponse]
                        resultArray.append(contentsOf: prevResult)
                        resultOpr.result = .success(resultArray)
                    } catch {
                        resultOpr.result = .failure(error)
                    }
                case .failure(let error):
                    resultOpr.result = .failure(error)
                }
            })
            adapterResultOpr.addDependency(opearation)
            resultOpr.addDependency(adapterResultOpr)
            operations.append(adapterResultOpr)
        }
        
        operations.append(resultOpr)
    }
}

public class SimpleFileUploadOperations: OperationsGenerator {
    
    public init() {}
    
    var operations: [Operation] = []
    
    public func getOperations(localFile: UploadJobLocalFile, completion: ((Result<VCSFileResponse, Error>) -> Void)? = nil) -> [Operation] {
        self.operations.removeAll()
        
        let getUploadURLOpr = GetUploadURLOperation(localFile: localFile)
        let uploadDataOpr = UploadDataOperation(vcsUplaodURL: nil, localFile: localFile)
        let adapterURLOpr = BlockOperation(block: {
            switch getUploadURLOpr.result {
            case .success(let value):
                uploadDataOpr.vcsUplaodURL = value
            case .failure(let error):
                uploadDataOpr.result = .failure(error)
            }
        })
        let getUplaodedFileDataOpr = GetUploadedFileDataOperation(localFile: localFile)
        let adapterUploadDataOpr = BlockOperation(block: {
            switch uploadDataOpr.result {
            case .success(let value):
                getUplaodedFileDataOpr.uploadResponseResult = value
            case .failure(let error):
                getUplaodedFileDataOpr.result = .failure(error)
            }
        })
        let updateLocalFileOperation = UpdateLocalFileOperation(localFile: localFile, fileResponse: nil)
        let adapterUpdateLocalOpr = BlockOperation(block: {
            switch getUplaodedFileDataOpr.result {
            case .success(let value):
                updateLocalFileOperation.fileResponse = value
            case .failure(let error):
                updateLocalFileOperation.result = .failure(error)
            }
        })
        
        getUploadURLOpr ==> adapterURLOpr ==> uploadDataOpr ==> adapterUploadDataOpr ==> getUplaodedFileDataOpr ==> adapterUpdateLocalOpr ==> updateLocalFileOperation
        
        self.operations.append(getUploadURLOpr)
        self.operations.append(adapterURLOpr)
        self.operations.append(uploadDataOpr)
        self.operations.append(adapterUploadDataOpr)
        self.operations.append(getUplaodedFileDataOpr)
        self.operations.append(adapterUpdateLocalOpr)
        self.operations.append(updateLocalFileOperation)
        
        OperationsUtils.appendFinalOperation(operations: &self.operations, lastUploadOperation: updateLocalFileOperation, operationID: localFile.rID, completion: completion)
        
        return self.operations
    }
}
