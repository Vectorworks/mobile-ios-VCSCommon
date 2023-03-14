import Foundation
import CocoaLumberjackSwift

@objc public class PDFFileUploadOperations: NSObject, OperationsGenerator {
    
    public override init() {}
    
    var operations: [Operation] = []
    
    @objc public static func objcStartOperations(_ PDFTempFile: URL, pdfMetadata: FileAsset, newName name: String, thumbnail: UploadJobLocalFile?, owner: String) {
        guard let unuploadedPDF = PDF.construct(relatedTo: pdfMetadata, withName: name, PDFTempFile: PDFTempFile, thumbnail: thumbnail) else { return }
        let operations = PDFFileUploadOperations().getOperations(localFile: unuploadedPDF)
        
        VCSBackgroundSession.default.operationQueue.addOperations(operations, waitUntilFinished: false)
    }
    
    public func getOperations(localFile: UploadJobLocalFile, completion: ((Result<VCSFileResponse, Error>) -> Void)? = nil) -> [Operation] {
        self.operations.removeAll()
        
        self.operations = SimpleFileUploadOperations().getOperations(localFile: localFile)
        self.operations.forEach { $0.vcsRemoveDependencies() }
        guard let uploadDataOpr = self.operations.first(where: { $0 is UploadDataOperation }) as? UploadDataOperation,
              let adapterURLOpr = self.operations.first(where: { $0 is BlockOperation }) as? BlockOperation,
              let getUploadedFileDataOpr = self.operations.first(where: { $0 is GetUploadedFileDataOperation }) as? GetUploadedFileDataOperation,
              let updateLocalFileOperation = self.operations.first(where: { $0 is UpdateLocalFileOperation }) as? UpdateLocalFileOperation,
              let adapterUpdateLocalOpr = self.operations.last(where: { $0 is BlockOperation }) as? BlockOperation else { return self.operations }
        
        self.operations.remove(object: updateLocalFileOperation)
        self.operations.remove(object: adapterUpdateLocalOpr)
        
        if localFile.related.count > 0 {
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
