import Foundation
import Dispatch

public class VCSBackgroungSession: NSObject {
    public static var `default` = VCSBackgroungSession()

    public var appGroupSetting: String? = nil
    public let sessionIdentifierBackground: String = "net.nemetschek.Nomad.MainApp.session.upload.background"

    @objc public lazy var backgroundSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: sessionIdentifierBackground)
        configuration.sharedContainerIdentifier = appGroupSetting
        let session = URLSession(configuration: configuration, delegate: VCSBackgroundUploader.default, delegateQueue: OperationQueue.main)
        return session
    }()
}

public class VCSBackgroundUploader: NSObject {
    public static var `default` = VCSBackgroundUploader()
    
    let uploadSemaphore = DispatchSemaphore(value: 0)
    public static var uploads = [String : URLSessionUploadTask]()
    public static var uploadsResponse = [String : URLResponse]()
    public static var uploadsResponseData = [String : Data]()
    public static var uploadsFuture = [String : Data]()
    
    
    func uploadFile(fileURL: URL, uploadURL: VCSUploadURL, progressForFile: FileAsset? = nil, onURLSessionTaskCreation: ((URLSessionTask) -> Void)? = nil) -> Future<VCSUploadDataResponse, Error> {
        print("###### uploadFile ---> \(Thread.current)")
        return Future<VCSUploadDataResponse, Error> { (completion) in
            guard let request = try? APIRouter.uploadFileURL(uploadURL: uploadURL).asURLRequest() else {
                completion(.failure(VCSNetworkError.GenericException("URL convetions failed")))
                return
            }
            print("###### Future ---> \(Thread.current)")
            let task = VCSBackgroungSession.default.backgroundSession.uploadTask(with: request, fromFile: fileURL)
            if let progressForFile = progressForFile {
                VCSBackgroundUploader.uploads[progressForFile.rID] = task
                VCSBackgroundUploader.uploadsResponseData[progressForFile.rID] = Data()
                APIClient.updateUploadProgress(progressForFile: progressForFile, progress: ProgressValues.Started.rawValue)
                task.taskDescription = progressForFile.rID
            }
            task.resume()
            switch VCSBackgroundUploader.default.uploadSemaphore.wait(timeout: .now() + 10) {
            case .success:
                if let progressForFileValue = progressForFile,
                    let receivedData = VCSBackgroundUploader.uploadsResponseData[progressForFileValue.rID],
                    let response = VCSBackgroundUploader.uploadsResponse[progressForFileValue.rID] as? HTTPURLResponse
                {
                    let resultDate = APIClient.getDateFromUploadResponse(response, data: receivedData)
                    let jsonResponse = try? JSONSerialization.jsonObject(with: receivedData, options: []) as? [String: Any]
                    let result = VCSUploadDataResponse(resultDate, googleDriveID: (jsonResponse?["id"] as? String), googleDriveVerID: (jsonResponse?["headRevisionId"] as? String))
                    APIClient.updateUploadProgress(progressForFile: progressForFileValue, progress: ProgressValues.Finished.rawValue)
                    completion(.success(result))
                }
                else {
                    completion(.failure(VCSNetworkError.GenericException("URL result convetion failed")))
                }
                return
            case .timedOut:
                completion(.failure(VCSNetworkError.GenericException("timedOut")))
                return
            }
        }
    }
}

extension VCSBackgroundUploader: URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        if let uploadTask = task as? URLSessionUploadTask, let itemID = uploadTask.taskDescription {
            let uploadProgress:Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
            
            let notificationName = Notification.Name("uploading:\(itemID)")
            var userInfo: [String : Any] = [:]
            userInfo["progress"] =  uploadProgress
            DispatchQueue.main.async { NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo) }
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let uploadTask = dataTask as? URLSessionUploadTask, let itemID = uploadTask.taskDescription {
            VCSBackgroundUploader.uploadsResponse[itemID] = response
        }
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let uploadTask = dataTask as? URLSessionUploadTask, let itemID = uploadTask.taskDescription {
            var receivedData = VCSBackgroundUploader.uploadsResponseData[itemID]
            receivedData?.append(data)
            VCSBackgroundUploader.uploadsResponseData[itemID] = receivedData
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let uploadTask = task as? URLSessionUploadTask, let itemID = uploadTask.taskDescription {
            NetworkLogger.log("urlSession(_ session: URLSession, task: -> TASK \(itemID) is done")
            if let receivedData = VCSBackgroundUploader.uploadsResponseData[itemID] {
                NetworkLogger.log("urlSession(_ session: URLSession, task: -> TASK result:\n\(String(data: receivedData, encoding: .utf8))")
            }
            
            
        } else {
            NetworkLogger.log("urlSession(_ session: URLSession, task: -> TASK is unknown")
        }
    }
}
