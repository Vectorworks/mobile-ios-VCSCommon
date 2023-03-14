import Foundation
import CocoaLumberjackSwift
import Dispatch

public class VCSBackgroundSession: NSObject {
    public static var `default` = VCSBackgroundSession()
    
    public override init() {
        self.operationQueue.maxConcurrentOperationCount = 3
        super.init()
    }
    
    public var appGroupSetting: String? = nil
    public let sessionIdentifierBackground: String = "net.nemetschek.Nomad.MainApp.session.upload.background"
    public var backgroundCompletionHandler: (() -> Void)?
    
    
    public let operationQueue = OperationQueue()
    
    internal var uploadJobs: [String: UploadDataOperation] = [:]
    public static var uploadsResponse = [String : VCSUploadDataResponse]()
    public static var uploadsResponseData = [String : Data]()
    
    @objc public lazy var backgroundSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: sessionIdentifierBackground)
        configuration.sharedContainerIdentifier = appGroupSetting
        configuration.isDiscretionary = false
        configuration.sessionSendsLaunchEvents = false
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    public static func updateUploadProgress(modelID: String, progress: Double) {
        NotificationCenter.postUploadNotification(modelID: modelID, progress: progress)
        DDLogDebug("Uploading \(modelID): \(progress)")
    }
}

extension VCSBackgroundSession: URLSessionDataDelegate {
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print("urlSessionDidFinishEvents")
        print(session)
        DispatchQueue.main.async { VCSBackgroundSession.default.backgroundCompletionHandler?() }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        if let uploadTask = task as? URLSessionUploadTask, let itemID = uploadTask.taskDescription {
            let uploadProgress:Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
            
            VCSBackgroundSession.updateUploadProgress(modelID: itemID, progress: Double(uploadProgress))
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let uploadTask = dataTask as? URLSessionUploadTask, let itemID = uploadTask.taskDescription {
            var receivedData = VCSBackgroundSession.uploadsResponseData[itemID] ?? Data()
            receivedData.append(data)
            VCSBackgroundSession.uploadsResponseData[itemID] = receivedData
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let uploadTask = task as? URLSessionUploadTask, let itemID = uploadTask.taskDescription {
            DDLogInfo("urlSession(_ session: URLSession, task: -> TASK \(itemID) is done")
            if let responseData = VCSBackgroundSession.uploadsResponseData[itemID], let uploadJob = self.uploadJobs[itemID], let httpResponse = task.response as? HTTPURLResponse {
                //DDLogInfo("urlSession(_ session: URLSession, task: -> TASK result:\n\(String(data: responseData, encoding: .utf8))")
                
                let resultDate = APIClient.getDateFromUploadResponse(httpResponse, data: responseData)
                let jsonResponse = try? JSONSerialization.jsonObject(with: responseData ?? Data(), options: []) as? [String: Any]
                let result = VCSUploadDataResponse(resultDate, googleDriveID: (jsonResponse?["id"] as? String), googleDriveVerID: (jsonResponse?["headRevisionId"] as? String))
                
                VCSBackgroundSession.updateUploadProgress(modelID: itemID, progress: Double(ProgressValues.Finished.rawValue))
                
                uploadJob.result = .success(result)
                uploadJob.state = .finished
            } else if let responseError = error{
                DDLogError("urlSession didCompleteWithError: \(responseError.localizedDescription)")
            } else {
                DDLogError("Taks \(task.taskDescription) is not completing correctly.")
            }
        } else {
            DDLogError("urlSession(_ session: URLSession, task: -> TASK is unknown")
        }
    }
}













