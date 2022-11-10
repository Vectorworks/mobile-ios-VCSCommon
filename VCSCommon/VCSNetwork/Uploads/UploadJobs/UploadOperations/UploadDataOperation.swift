import Foundation
import CocoaLumberjackSwift

class UploadDataOperation: AsyncOperation {
    var vcsUplaodURL: VCSUploadURL?
    var localFile: UploadJobLocalFile
    var session: VCSBackgroundSession
    var backgroundTask: URLSessionUploadTask? = nil
    
    var result: Result<VCSUploadDataResponse, Error> = .failure(VCSError.OperationNotExecuted)
    
    init(vcsUplaodURL: VCSUploadURL?, localFile: UploadJobLocalFile, session: VCSBackgroundSession = VCSBackgroundSession.default) {
        self.vcsUplaodURL = vcsUplaodURL
        self.session = session
        self.localFile = localFile
        
        super.init()
        self.name = self.localFile.rID
        self.session.uploadJobs[self.localFile.rID] = self
    }
    
    override func main() {
        guard self.localFile.uploadPathURL.exists else {
            DDLogInfo("File does not exists: \(self.localFile.uploadPathURL)")
            self.localFile.uploadingState = .Error
            self.localFile.addToCache()
            self.state = .finished
            return
        }
        guard let uploadURL = self.vcsUplaodURL, let request = try? APIRouter.uploadFileURL(uploadURL: uploadURL).asURLRequest() else {
            DDLogInfo("URL convetions failed")
            self.localFile.uploadingState = .Error
            self.localFile.addToCache()
            self.state = .finished
            return
        }
        
        DDLogInfo("Executing UploadDataOperation")
        DDLogVerbose("Executing \(String(describing: self)) - with params: operationID: \(self.localFile.name), vcsUplaodURL: \(uploadURL.url), size: \(self.localFile.size), localFileURL: \(self.localFile.uploadPathURL)")
        
        self.localFile.uploadingState = .Uploading
        self.localFile.addToCache()
        
        backgroundTask = session.backgroundSession.uploadTask(with: request, fromFile: self.localFile.uploadPathURL)
        backgroundTask?.taskDescription = self.localFile.rID
        backgroundTask?.countOfBytesClientExpectsToSend = Int64(self.localFile.sizeAsInt + 1024);
        backgroundTask?.resume()
        
        VCSBackgroundSession.updateUploadProgress(modelID: self.localFile.rID, progress: Double(ProgressValues.Started.rawValue))
    }
}
