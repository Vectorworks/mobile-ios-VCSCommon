import Foundation
import CocoaLumberjackSwift

class PatchPDFOperation: AsyncOperation {
    var localFile: UploadJobLocalFile
    var fileWithRelatedResult: FileWithRelatedАRGS?
    var uploadResponseResult: VCSUploadDataResponse?
    
    var backgroundTask: URLSessionUploadTask? = nil
    
    var result: Result<VCSEmptyResponse, Error> = .failure(VCSError.OperationNotExecuted("PatchPDFOperation"))
    
    init(localFile: UploadJobLocalFile, fileWithRelatedResult: FileWithRelatedАRGS?) {
        self.localFile = localFile
        self.fileWithRelatedResult = fileWithRelatedResult
        
        super.init()
        self.name = self.localFile.rID
    }
    
    override func main() {
        //TODO: ii move uplaod response to job object
        guard let uploadResponse = uploadResponseResult,
              let fileWithRelated = fileWithRelatedResult,
              fileWithRelated.uploadedRelatedFiles.count > 0,
              let bodyData = try? JSONSerialization.data(withJSONObject: ["related_files": fileWithRelated.uploadedRelatedFiles.map { $0.resourceURI }]) else {
            DDLogInfo("Skipping PatchPDFOperation - \(localFile.name)")
            self.result = .success(VCSEmptyResponse())
            self.state = .finished
            return
        }
        
        DDLogInfo("Executing PatchPDFOperation")
        DDLogVerbose("Executing \(String(describing: self)) - with params: operationID: \(self.localFile.name), file: \(self.localFile.name), fileWithRelated: \(fileWithRelated.uploadedFile.name), fileWithRelated: \(fileWithRelated.uploadedRelatedFiles.compactMap({ $0.name}))")
        
        APIClient.patchFile(owner: self.localFile.ownerLogin, storage: self.localFile.storageTypeString, filePrefix: self.localFile.prefix, updateFromStorage: true, bodyData: bodyData, googleDriveID: uploadResponse.googleDriveID, googleDriveVerID: uploadResponse.googleDriveVerID).execute { (result: Result<VCSEmptyResponse, Error>) in
            self.result = result
            self.state = .finished
        }
    }
}
