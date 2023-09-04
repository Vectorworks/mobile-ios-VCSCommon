import Foundation
import CocoaLumberjackSwift

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
            
            switch resultOpr.result {
            case .failure(let error):
                DDLogError("Error on single upload. \(error.localizedDescription)")
            case .success(_):
                break
            }
        })
        
        adapterResultOpr.addDependency(lastUploadOperation)
        resultOpr.addDependency(adapterResultOpr)
        
        operations.append(adapterResultOpr)
        operations.append(resultOpr)
    }
    
    static func appendFinalOperation(operations: inout [Operation], lastUploadOperations: [UpdateLocalFileOperation], operationID: String, completion: ((Result<[VCSFileResponse], Error>) -> Void)? = nil) {
        guard let finalOpr = completion else { return }
        
        let resultOpr = ArrayResultOperation(operationID: operationID, completion: finalOpr)
        lastUploadOperations.forEach { operation in
            let adapterResultOpr = BlockOperation(block: {
                switch operation.result {
                case .success(let fileResponse):
                    do {
                        let prevResult = try resultOpr.result.get()
                        var resultArray = [fileResponse]
                        resultArray.append(contentsOf: prevResult)
                        resultOpr.result = .success(resultArray)
                    } catch let error {
                        resultOpr.result = .failure(error)
                    }
                case .failure(let error):
                    resultOpr.result = .failure(error)
                }
                
                switch resultOpr.result {
                case .failure(let error):
                    DDLogError("Error on multi upload. \(error.localizedDescription)")
                case .success(_):
                    break
                }
            })
            operation ==> adapterResultOpr ==> resultOpr
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
        
        let uploadDataOpr = UploadDataOperation(localFile: localFile)
        let getUploadedFileDataOpr = GetUploadedFileDataOperation(localFile: localFile)
        let adapterUploadDataOpr = BlockOperation(block: {
            switch uploadDataOpr.result {
            case .success(let value):
                getUploadedFileDataOpr.uploadResponseResult = value
            case .failure(let error):
                getUploadedFileDataOpr.result = .failure(error)
            }
        })
        let updateLocalFileOperation = UpdateLocalFileOperation(localFile: localFile, fileResponse: nil)
        let adapterUpdateLocalOpr = BlockOperation(block: {
            switch getUploadedFileDataOpr.result {
            case .success(let value):
                updateLocalFileOperation.fileResponse = value
            case .failure(let error):
                updateLocalFileOperation.result = .failure(error)
            }
        })
        
        uploadDataOpr ==> adapterUploadDataOpr ==> getUploadedFileDataOpr ==> adapterUpdateLocalOpr ==> updateLocalFileOperation
        
        self.operations.append(uploadDataOpr)
        self.operations.append(adapterUploadDataOpr)
        self.operations.append(getUploadedFileDataOpr)
        self.operations.append(adapterUpdateLocalOpr)
        self.operations.append(updateLocalFileOperation)
        
        
        //PDF and related files
        if localFile.related.count > 0 {
            guard let uploadDataOpr = self.operations.first(where: { $0 is UploadDataOperation }) as? UploadDataOperation,
                  let adapterURLOpr = self.operations.first(where: { $0 is BlockOperation }) as? BlockOperation,
                  let getUploadedFileDataOpr = self.operations.first(where: { $0 is GetUploadedFileDataOperation }) as? GetUploadedFileDataOperation,
                  let updateLocalFileOperation = self.operations.first(where: { $0 is UpdateLocalFileOperation }) as? UpdateLocalFileOperation,
                  let adapterUpdateLocalOpr = self.operations.last(where: { $0 is BlockOperation }) as? BlockOperation else { return self.operations }
            
            self.operations.forEach { $0.vcsRemoveDependencies() }
            
            self.operations.remove(object: updateLocalFileOperation)
            self.operations.remove(object: adapterUpdateLocalOpr)
        
            var relatedFilesOperations: [Operation] = []
            var relatedFileGetUploadedOperations: [GetUploadedFileDataOperation] = []
            localFile.related.forEach {
                relatedFilesOperations.append(contentsOf: SimpleFileUploadOperations().getOperations(localFile: $0))
                if let lastOperation = relatedFilesOperations.last(where: { $0 is GetUploadedFileDataOperation }) as? GetUploadedFileDataOperation {
                    relatedFileGetUploadedOperations.append(lastOperation)
                    DDLogInfo("ASD ---: \(lastOperation.localFile.name)")
                }
            }
            
            let patchPDFOpr = PatchPDFOperation(localFile: localFile, fileWithRelatedResult: nil)
            let adapterPatchOpr = BlockOperation(block: {
                var vcsFile: VCSFileResponse?
                var vcsRelatedFiles: [VCSFileResponse] = []
                switch getUploadedFileDataOpr.result {
                case .success(let value):
                    vcsFile = value
                case .failure(let error):
                    patchPDFOpr.result = .failure(error)
                    DDLogError("getUploadedFileDataOpr error: \(error.localizedDescription)")
                }
                relatedFileGetUploadedOperations.forEach {
                    switch $0.result {
                    case .success(let value):
                        vcsRelatedFiles.append(value)
                    case .failure(let error):
                        patchPDFOpr.result = .failure(error)
                        DDLogError("relatedFileGetUploadedOperations error: \(error.localizedDescription)")
                    }
                }
                if let vcsFile {
                    patchPDFOpr.fileWithRelatedResult = (vcsFile, vcsRelatedFiles)
                }
                switch uploadDataOpr.result {
                case .success(let value):
                    patchPDFOpr.uploadResponseResult = value
                case .failure(let error):
                    patchPDFOpr.result = .failure(error)
                    DDLogError("uploadDataOpr error: \(error.localizedDescription)")
                }
            })
            
            let getUploadedPDFFileDataOpr = GetUploadedFileDataOperation(localFile: localFile)
            let adapterGetUploadedPDFOpr = BlockOperation(block: {
                switch patchPDFOpr.result {
                case .success(_):
                    getUploadedPDFFileDataOpr.uploadResponseResult = patchPDFOpr.uploadResponseResult
                case .failure(let error):
                    getUploadedPDFFileDataOpr.result = .failure(error)
                    DDLogError("adapterGetUploadedPDFOpr error: \(error.localizedDescription)")
                }
            })
            
            let updateLocalPDFOperation = UpdateLocalFileOperation(localFile: localFile, fileResponse: nil)
            let adapterUpdateLocalPDFOpr = BlockOperation(block: {
                switch getUploadedPDFFileDataOpr.result {
                case .success(let value):
                    updateLocalPDFOperation.fileResponse = value
                case .failure(let error):
                    updateLocalPDFOperation.result = .failure(error)
                }
            })
            
            relatedFileGetUploadedOperations.forEach { $0 ==> adapterURLOpr }
            uploadDataOpr ==> adapterURLOpr ==> getUploadedFileDataOpr ==> adapterPatchOpr ==> patchPDFOpr ==> adapterGetUploadedPDFOpr ==> getUploadedPDFFileDataOpr ==> adapterUpdateLocalPDFOpr ==> updateLocalPDFOperation
            
            self.operations.append(contentsOf: relatedFilesOperations)
            self.operations.append(adapterPatchOpr)
            self.operations.append(patchPDFOpr)
            self.operations.append(adapterGetUploadedPDFOpr)
            self.operations.append(getUploadedPDFFileDataOpr)
            self.operations.append(adapterUpdateLocalPDFOpr)
            self.operations.append(updateLocalPDFOperation)
            
            OperationsUtils.appendFinalOperation(operations: &self.operations, lastUploadOperation: updateLocalPDFOperation, operationID: localFile.rID, completion: completion)
        } else {
            OperationsUtils.appendFinalOperation(operations: &self.operations, lastUploadOperation: updateLocalFileOperation, operationID: localFile.rID, completion: completion)
        }
        
        return self.operations
    }
}

extension Operation {
    func vcsRemoveDependencies() {
        let dependencies = self.dependencies
        dependencies.forEach { self.removeDependency($0) }
    }
}
