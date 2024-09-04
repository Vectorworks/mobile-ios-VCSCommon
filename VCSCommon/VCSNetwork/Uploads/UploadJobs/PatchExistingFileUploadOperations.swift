import Foundation
import CocoaLumberjackSwift

public class PatchExistingFileUploadOperations: OperationsGenerator {
    
    public init() {}
    
    var operations: [Operation] = []
    
    public func getOperations(localFile: UploadJobLocalFile, completion: ((Result<VCSFileResponse, Error>) -> Void)? = nil) -> [Operation] {
        self.operations.removeAll()
        
        guard let parentPatchFile = localFile.parentPatchFile else {
            completion?(.failure(VCSError.noInitialData))
            return []
            //TODO: check errors
        }
        
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
        
        let patchFileOpr = PatchPDFOperation(localFile: localFile, fileWithRelatedResult: nil)
        let adapterPatchOpr = BlockOperation(block: {
            var vcsRelatedFiles: [VCSFileResponse] = []
            switch getUploadedFileDataOpr.result {
            case .success(let value):
                vcsRelatedFiles.append(value)
            case .failure(let error):
                patchFileOpr.result = .failure(error)
                DDLogError("relatedFileGetUploadedOperations error: \(error.localizedDescription)")
            }
            
            patchFileOpr.fileWithRelatedResult = (parentPatchFile, vcsRelatedFiles)
            
            switch uploadDataOpr.result {
            case .success(let value):
                patchFileOpr.uploadResponseResult = value
            case .failure(let error):
                patchFileOpr.result = .failure(error)
                DDLogError("uploadDataOpr error: \(error.localizedDescription)")
            }
        })
        
        let getFileDataOpr = GetFileDataOperation(file: parentPatchFile)
        let updateParentLocalFileOperation = UpdateLocalFileOperation(localFile: UploadJobLocalFile(file: parentPatchFile), fileResponse: nil)
        let adapterUpdateParentLocalOpr = BlockOperation(block: {
            switch getFileDataOpr.result {
            case .success(let value):
                updateParentLocalFileOperation.fileResponse = value
            case .failure(let error):
                updateParentLocalFileOperation.result = .failure(error)
            }
        })
        
        uploadDataOpr ==> adapterUploadDataOpr ==> getUploadedFileDataOpr ==> adapterUpdateLocalOpr ==> updateLocalFileOperation ==> adapterPatchOpr ==> patchFileOpr  ==> getFileDataOpr ==> adapterUpdateParentLocalOpr ==> updateParentLocalFileOperation
        
        self.operations.append(uploadDataOpr)
        self.operations.append(adapterUploadDataOpr)
        self.operations.append(getUploadedFileDataOpr)
        self.operations.append(adapterUpdateLocalOpr)
        self.operations.append(updateLocalFileOperation)
        self.operations.append(adapterPatchOpr)
        self.operations.append(patchFileOpr)
        self.operations.append(getFileDataOpr)
        self.operations.append(adapterUpdateParentLocalOpr)
        self.operations.append(updateParentLocalFileOperation)
        
        OperationsUtils.appendFinalOperation(operations: &self.operations, lastUploadOperation: updateParentLocalFileOperation, operationID: localFile.rID, completion: completion)
        
        return self.operations
    }
}
