import Foundation
import CocoaLumberjackSwift

class UploadDataOperation: AsyncOperation {
    var localFile: UploadJobLocalFile
    var session: VCSBackgroundSession
    var backgroundTask: URLSessionUploadTask? = nil
    
    var result: Result<VCSUploadDataResponse, Error> = .failure(VCSError.OperationNotExecuted)
    
    init(localFile: UploadJobLocalFile, session: VCSBackgroundSession = VCSBackgroundSession.default) {
        self.session = session
        self.localFile = localFile
        
        super.init()
        self.name = self.localFile.rID
        self.session.uploadJobs[self.localFile.rID] = self
    }
    
    override func main() {
        DDLogInfo("Executing GetUploadURLOperation")
        DDLogVerbose("Executing \(String(describing: self)) - with params: operationID: \(self.localFile.name), owner: \(self.localFile.ownerLogin), storage: \(self.localFile.storageTypeString), filePrefix: \(self.localFile.prefix), size: \(self.localFile.size)")
        
        self.localFile.uploadingState = .Waiting
        VCSCache.addToCache(item: self.localFile)
        APIClient.getUploadURL(owner: self.localFile.ownerLogin, storage: self.localFile.storageTypeString, filePrefix: self.localFile.prefix, size: self.localFile.sizeAsInt).execute(onSuccess: { (result: VCSUploadURL) in
            self.localFile.uploadingState = .Uploading
            VCSCache.addToCache(item: self.localFile)
            
            guard self.localFile.uploadPathURL.exists else {
                DDLogInfo("File does not exists: \(self.localFile.uploadPathURL)")
                self.localFile.uploadingState = .Error
                VCSCache.addToCache(item: self.localFile)
                self.state = .finished
                return
            }
            guard let request = try? APIRouter.uploadFileURL(uploadURL: result).asURLRequest() else {
                DDLogInfo("URL convetions failed")
                self.localFile.uploadingState = .Error
                VCSCache.addToCache(item: self.localFile)
                self.state = .finished
                return
            }
            
            DDLogInfo("Executing UploadDataOperation")
            DDLogVerbose("Executing \(String(describing: self)) - with params: operationID: \(self.localFile.name), vcsUplaodURL: \(result.url), size: \(self.localFile.size), localFileURL: \(self.localFile.uploadPathURL)")
            
            self.backgroundTask = self.session.backgroundSession.uploadTask(with: request, fromFile: self.localFile.uploadPathURL)
            self.backgroundTask?.taskDescription = self.localFile.rID
            self.backgroundTask?.countOfBytesClientExpectsToSend = Int64(self.localFile.sizeAsInt + 1024);
            self.backgroundTask?.resume()
            
            VCSBackgroundSession.updateUploadProgress(modelID: self.localFile.rID, progress: Double(ProgressValues.Started.rawValue))
        }, onFailure: { (error: Error) in
            self.result = .failure(error)
            self.state = .finished
        })
    }
}
