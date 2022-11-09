import Foundation

@objc public class PDFFileUploadOperations: NSObject, OperationsGenerator {
    
    public override init() {}
    
    var operations: [Operation] = []
    
    @objc public static func objcStartOperations(_ PDFTempFile: URL, pdfMetadata: FileAsset, newName name: String, thumbnail: UploadJobLocalFile?, owner: String) {
        let unuploadedPDF = PDF.construct(relatedTo: pdfMetadata, withName: name, PDFTempFile: PDFTempFile, thumbnail: thumbnail)
        let operations = PDFFileUploadOperations().getOperations(localFile: unuploadedPDF)
        
        VCSBackgroundSession.default.operationQueue.addOperations(operations, waitUntilFinished: false)
    }
    
    public func getOperations(localFile: UploadJobLocalFile, completion: ((Result<VCSFileResponse, Error>) -> Void)? = nil) -> [Operation] {
        self.operations.removeAll()
        
        self.operations = SimpleFileUploadOperations().getOperations(localFile: localFile)
        guard let getUploadURLOpr = self.operations.first(where: { $0 is GetUploadURLOperation }) as? GetUploadURLOperation,
              let uploadDataOpr = self.operations.first(where: { $0 is UploadDataOperation }) as? UploadDataOperation,
              let adapterURLOpr = self.operations.first(where: { $0 is BlockOperation }) as? BlockOperation,
              let getUploadedFileDataOpr = self.operations.first(where: { $0 is GetUploadedFileDataOperation }) as? GetUploadedFileDataOperation else { return self.operations }
        
        if localFile.related.count > 0 {
            var relatedFilesOperations: [Operation] = []
            var relatedFileGetUploadedOperations: [GetUploadedFileDataOperation] = []
            localFile.related.forEach {
                relatedFilesOperations.append(contentsOf: SimpleFileUploadOperations().getOperations(localFile: $0))
                if let lastOperation = relatedFilesOperations.last as? GetUploadedFileDataOperation {
                    relatedFileGetUploadedOperations.append(lastOperation)
                }
            }
            
            let patchPDFOpr = PatchPDFOperation(localFile: localFile, fileWithRelatedResult: nil)
            let adapterURLOpr = BlockOperation(block: {
                var vcsFile: VCSFileResponse?
                var vcsRelatedFiles: [VCSFileResponse] = []
                switch getUploadedFileDataOpr.result {
                case .success(let value):
                    vcsFile = value
                case .failure(let error):
                    patchPDFOpr.result = .failure(error)
                }
                relatedFileGetUploadedOperations.forEach {
                    switch $0.result {
                    case .success(let value):
                        vcsRelatedFiles.append(value)
                    case .failure(let error):
                        patchPDFOpr.result = .failure(error)
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
                }
            })
            let getUploadedPDFFileDataOpr = GetUploadedFileDataOperation(localFile: localFile)
            
            let updateLocalFileOperation = UpdateLocalFileOperation(localFile: localFile, fileResponse: nil)
            let adapterUpdateLocalOpr = BlockOperation(block: {
                switch getUploadedFileDataOpr.result {
                case .success(let value):
                    updateLocalFileOperation.fileResponse = value
                case .failure(let error):
                    updateLocalFileOperation.result = .failure(error)
                }
            })
            
            relatedFileGetUploadedOperations.forEach { $0 ==> adapterURLOpr }
            uploadDataOpr ==> adapterURLOpr ==> patchPDFOpr ==> getUploadedPDFFileDataOpr ==> adapterUpdateLocalOpr ==> updateLocalFileOperation
            
            self.operations.append(contentsOf: relatedFilesOperations)
            self.operations.append(adapterURLOpr)
            self.operations.append(patchPDFOpr)
            self.operations.append(getUploadedPDFFileDataOpr)
            self.operations.append(adapterUpdateLocalOpr)
            self.operations.append(updateLocalFileOperation)
            
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
