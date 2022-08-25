import Foundation
import Alamofire
import os
import CocoaLumberjackSwift
import SafariServices
import OAuth2

public enum VCSNetworkError: Error {
    case GenericException(String)
    case parsingError(String)
}

public class VCSFlagStates {
    public static let related = false
    public static let versioning = false
    
    public static let flags = true
    public static let ownerInfo = true
    public static let thumbnail3D = true
    public static let fileType = true
    public static let sharingInfo = true
}

public class APIClient: NSObject {
    private static var SFDelegate = APIClient()
    private static var SFDelegateOnSuccess: (() -> Void)?
    private static var SFDelegateOnFail: ((Error) -> Void)?
    private static weak var SFDelegatePresenter: UIViewController?
    
    @objc public static let LogoutClearFieldsNotificationName: String = "VCSLogoutClearFields"
    @objc public static let ssoCustomRedirectURI: String = "vcsnomad://oauth-callback/ssologin"
    
    public static var LogoutClearFieldsNotification: Notification.Name { return Notification.Name(rawValue: APIClient.LogoutClearFieldsNotificationName) }
    public static var hasNetworkConnectivity: Bool { return VCSReachability.default.netStatus != .unavailable }
    public static var loggingEnabled: Bool = false
    public static var isAnonymousMode: Bool = false
    public static var lastErrorData: Data?
    public static var lastErrorResponse: String? { String(data: APIClient.lastErrorData ?? Data(), encoding: .utf8)}
    
    public static var isDisconnectedOrInAnonymousMode: Bool { return !APIClient.hasNetworkConnectivity || APIClient.isAnonymousMode }
    
    public private(set) static var oauth2Client: OAuth2CodeGrant?
    public private(set) static var oauth2RetryHandler: OAuth2RetryHandler?
    
    public class func setOAuth2Swift(presenter: UIViewController, modalPresentationStyle: UIModalPresentationStyle = .fullScreen) {
        APIClient.oauth2Client?.authConfig.authorizeEmbedded = true
        APIClient.oauth2Client?.authConfig.authorizeContext = presenter
        APIClient.oauth2Client?.authConfig.ui.modalPresentationStyle = modalPresentationStyle
        APIClient.oauth2Client?.afterAuthorizeOrFail = {
            guard let error = $1 else { return }
            
            if error == OAuth2Error.requestCancelled {
                APIClient.oauth2RetryHandler?.userDidCancelSingIn = true
            }
            DDLogError("afterAuthorizeOrFail - \(error)")
        }
        APIClient.oauth2RetryHandler?.userDidCancelSingIn = false
    }
    
    internal class func updateOAuthClient(loginSettings: VCSLoginSettingsResponse, redirectURI: String? = nil, sharedGroup: String? = nil) {
        //Dev option to debug frameworks easier
        var redirectURIs = loginSettings.nomadRedirectURLs
        if let rURI = redirectURI {
            redirectURIs = [rURI]
        }
        
        var settings = [
            "client_id": loginSettings.nomadClientID,
            "authorize_uri": loginSettings.loginServer.stringByAppendingPath(path: loginSettings.oAuthAuthorizeURL),
            "token_uri": loginSettings.loginServer.stringByAppendingPath(path: loginSettings.oAuthTokenURL),
            "redirect_uris": redirectURIs,
            "use_pkce": true,
            "secret_in_body": true,
            "token_prefix": "Token",
            "token_assume_unexpired": false
        ] as OAuth2JSON
        if let vSharedGroup = sharedGroup {
            settings = [
                "client_id": loginSettings.nomadClientID,
                "authorize_uri": loginSettings.loginServer.stringByAppendingPath(path: loginSettings.oAuthAuthorizeURL),
                "token_uri": loginSettings.loginServer.stringByAppendingPath(path: loginSettings.oAuthTokenURL),
                "redirect_uris": redirectURIs,
                "use_pkce": true,
                "secret_in_body": true,
                "token_prefix": "Token",
                "token_assume_unexpired": false,
                "keychain_access_group": vSharedGroup
            ] as OAuth2JSON
        }
        
        let oauth2Client =  OAuth2CodeGrant(settings: settings)
        oauth2Client.clientConfig.contentType = .json
        APIClient.oauth2Client = oauth2Client
        APIClient.oauth2RetryHandler = OAuth2RetryHandler(oauth2: APIClient.oauth2Client)
    }
    
    public static func clearAllFields() {
        self.clearCookies()
        AuthCenter.shared.clearAllFields()
        URLCache.shared.removeAllCachedResponses()
        APIClient.oauth2Client?.forgetTokens()
        
        let logoutClearFieldsNotification = Notification.init(name: Notification.Name(rawValue: APIClient.LogoutClearFieldsNotificationName))
        NotificationCenter.default.post(logoutClearFieldsNotification)
    }
    
    public static func clearCookies() {
        HTTPCookieStorage.shared.cookies?.forEach() { HTTPCookieStorage.shared.deleteCookie($0) }
    }
    
    @discardableResult
    private static func performRequest<S:Decodable, E:Error>(route: APIRouter, decoder: DataDecoder = JSONDecoder()) -> Future<S, E> {
        return Future(operation: { completion in
            AF.request(route, interceptor: APIClient.oauth2RetryHandler).responseDecodable(decoder: decoder, completionHandler: { (dataResponse: DataResponse<S, AFError>) in
                APIClient.lastErrorData = nil
                switch dataResponse.result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    //HACK THIS!!!
                    if error.responseCode == 5,
                        let emptyData = "{}".data(using: .utf8),
                        let res = try? decoder.decode(S.self, from: emptyData) {
                        completion(.success(res))
                        return
                    } else if error.isResponseSerializationError,
                        let emptyData = "{}".data(using: .utf8),
                        let res = try? decoder.decode(S.self, from: emptyData) {
                        completion(.success(res))
                        return
                    }
                    
                    APIClient.lastErrorData = dataResponse.data
                    NetworkLogger.log("##### VCSNetwork error:\t\(dataResponse)")
                    NetworkLogger.log("##### VCSNetwork error code:\t\(dataResponse.response?.statusCode ?? 0)")
                    NetworkLogger.log("##### VCSNetwork error URL:\t\(dataResponse.request?.url?.absoluteString ?? "")")
                    if let errorData = dataResponse.data {
                        NetworkLogger.log("##### VCSNetwork data:\t\(String(data: errorData, encoding: .utf8) ?? "nil")")
                    }
                    
                    completion(.failure(error as! E))
                }
            }).validate()
        })
    }
    
    public static func loginSettings() -> Future<VCSLoginSettingsResponse, Error> {
        return performRequest(route: APIRouter.loginSettings)
    }
    
    public static func awsKeys() -> Future<AWSKeysResponse, Error> {
        return performRequest(route: APIRouter.awsKeys)
    }
    
    public static func vcsUser() -> Future<VCSUserResponse, Error> {
        return performRequest(route: APIRouter.vcsUser)
    }
    
    public static func listFolder(possibleFolderURI: String?) -> Future<VCSFolderResponse, Error> {
        guard let folderURI = possibleFolderURI else { return Future(error: VCSNetworkError.parsingError("Folder list is empty")) }
        return performRequest(route: APIRouter.listFolder(folderURI: folderURI))
    }
    
    public static func createFolder(storage: StorageType, name: String, parentFolderPrefix: String?, owner: String?) -> Future<VCSFolderResponse, Error> {
        guard let userLogin = owner else { return Future(error: VCSNetworkError.parsingError("Owner is nil")) }
        var folderPrefix = parentFolderPrefix ?? ""
        folderPrefix = folderPrefix.stringByAppendingPath(path: name)
        
        var folderURLPath = "o:\(userLogin)"
        folderURLPath = folderURLPath.stringByAppendingPath(path: "p:\(folderPrefix)")
        folderURLPath = folderURLPath.VCSNormalizedURLString()
        
        return performRequest(route: APIRouter.createFolder(storage: storage, folderURI: folderURLPath))
    }
    
    public static func folderStats(owner: String, possibleFolderURI: String?) -> Future<VCSFolderStatResponse, Error> {
        guard let folderURI = possibleFolderURI else { return Future(error: VCSNetworkError.parsingError("Folder list is empty")) }
        return performRequest(route: APIRouter.folderStats(owner: owner, folderURI: folderURI))
    }
    
    public static func listStorage() -> Future<StorageList, Error> {
        return performRequest(route: APIRouter.listStorage)
    }
    
    public static func getStoragePagesList(storagePagesURI: String) -> Future<StoragePagesList, Error> {
        return performRequest(route: APIRouter.getStoragePagesList(storagePagesURI: storagePagesURI))
    }
    
    public static func sendFeedback(data: FeedbackRequest) -> Future<VCSFeedbackResultResponse, Error> {
        return performRequest(route: APIRouter.sendFeedback(feedbackData: data))
    }
    
    public static func listSharedWithMe() -> Future<VCSSharedWithMeResponse, Error> {
        return performRequest(route: APIRouter.listSharedWithMe)
    }
    
    public static func listSharedFolder() -> Future<SharedFolderResponse, Error> {
        return performRequest(route: APIRouter.listSharedFolder)
    }
    
    public static func fileData(owner: String, storage: String, filePrefix: String, updateFromStorage: Bool = false, googleDriveID: String? = nil, googleDriveVerID: String? = nil) -> Future<VCSFileResponse, Error> {
        return performRequest(route: APIRouter.fileData(owner: owner, storage: storage, filePrefix: filePrefix, updateFromStorage: updateFromStorage, googleDriveID: googleDriveID, googleDriveVerID: googleDriveVerID))
    }
    
    public static func patchFile(owner: String, storage: String, filePrefix: String, updateFromStorage: Bool = false, bodyData: Data, googleDriveID: String? = nil, googleDriveVerID: String? = nil) -> Future<VCSEmptyResponse, Error> {
        return performRequest(route: APIRouter.patchFile(owner: owner, storage: storage, filePrefix: filePrefix, updateFromStorage: updateFromStorage, data: bodyData, googleDriveID: googleDriveID, googleDriveVerID: googleDriveVerID))
    }
    
    public static func getUploadURL(owner: String, storage: String, filePrefix: String, size: Int) -> Future<VCSUploadURL, Error> {
        return performRequest(route: APIRouter.getUploadURL(owner: owner, storage: storage, filePrefix: filePrefix, size: size))
    }
    
    public static func uploadFileURL(fileURL: URL, uploadURL: VCSUploadURL, progressForFile: FileAsset? = nil, onURLSessionTaskCreation: ((URLSessionTask) -> Void)? = nil) -> Future<VCSUploadDataResponse, Error> {
        return Future { (completion) in
            let uploadRequest = AF.upload(fileURL, with: APIRouter.uploadFileURL(uploadURL: uploadURL))
            if let progressForFile = progressForFile {
                APIClient.uploads[progressForFile.rID] = uploadRequest
                APIClient.updateUploadProgress(progressForFile: progressForFile, progress: ProgressValues.Started.rawValue)
            }
            
            uploadRequest.response { (dataResponse: DataResponse<Data?, AFError>) in
                switch dataResponse.result {
                case .success(let value):
                    let resultDate = getDateFromUploadResponse(dataResponse.response, data: value)
                    let jsonResponse = try? JSONSerialization.jsonObject(with: value ?? Data(), options: []) as? [String: Any]
                    let result = VCSUploadDataResponse(resultDate, googleDriveID: (jsonResponse?["id"] as? String), googleDriveVerID: (jsonResponse?["headRevisionId"] as? String))
                    if let progressForFile = progressForFile {
                        Uploader.uploadResponses[progressForFile.rID] = result
                    }
                    APIClient.updateUploadProgress(progressForFile: progressForFile, progress: ProgressValues.Finished.rawValue)
                    completion(.success(result))
                case .failure(let error):
                    DDLogInfo("APIClient.uploadData - failure")
                    APIClient.lastErrorData = dataResponse.data
                    NetworkLogger.log("##### VCSNetwork error:\t\(dataResponse)")
                    NetworkLogger.log("##### VCSNetwork error code:\t\(dataResponse.response?.statusCode ?? 0)")
                    NetworkLogger.log("##### VCSNetwork error URL:\t\(dataResponse.request?.url?.absoluteString ?? "")")
                    if let errorData = dataResponse.data {
                        NetworkLogger.log("##### VCSNetwork data:\t\(String(data: errorData, encoding: .utf8) ?? "nil")")
                    }
                    completion(.failure(error))
                }
            }
            
            uploadRequest.uploadProgress { (progress: Progress) in
                APIClient.updateUploadProgress(progressForFile: progressForFile, progress: progress.fractionCompleted)
            }
            
            if let onURLSessionTaskCreationValue = onURLSessionTaskCreation {
                uploadRequest.onURLSessionTaskCreation(perform: onURLSessionTaskCreationValue)
            }
            
            uploadRequest.validate()
        }
    }
    
    private static func updateUploadProgress(progressForFile: FileAsset?, progress: Double) {
        guard let file = progressForFile else { return }
        NotificationCenter.postUploadNotification(model: file, progress: progress)
        DDLogInfo("Uploading \(file.name): \(progress)")
    }
    
    @available(*, deprecated, renamed: "deleteAsset")
    public static func deleteData(resourceURL: String) -> Future<VCSEmptyResponse, Error> {
        return performRequest(route: APIRouter.deleteResource(resourceURL: resourceURL.VCSNormalizedURLString()))
    }
    
    public static func deleteAsset(asset: Asset) -> Future<VCSEmptyResponse, Error> {
        return performRequest(route: APIRouter.deleteAsset(asset: asset))
    }
    
    public static func jobData(jobID: String) -> Future<VCSJobResponse, Error> {
        return performRequest(route: APIRouter.job(jobID: jobID))
    }
    
    public static func listJobs(initialRequest: Bool = false) -> Future<JobsResponse, Error> {
        return performRequest(route: APIRouter.listJobs(initialRequest: initialRequest))
    }
    
    public static func unssenNotificationsIDs() -> Future<AnnouncementsResponse, Error> {
        return performRequest(route: APIRouter.unssenNotificationsIDs)
    }
    
    public static func clearNotifications(IDsHolder: ClearNotificationHolder) -> Future<AnnouncementsResponse, Error> {
        return performRequest(route: APIRouter.clearNotifications(IDsHolder: IDsHolder))
    }
    
    public static func processFile(filePrefix: String, storageType: String, owner: String, jobType: String) -> Future<VCSJobResponse, Error> {
        return performRequest(route: APIRouter.processFile(filePrefix: filePrefix, storageType: storageType, owner: owner, jobType: jobType))
    }
    
    public static func processPhotogram(jobData: PhotogramJobRequest) -> Future<VCSJobResponse, Error> {
        return performRequest(route: APIRouter.processPhotogram(jobData: jobData))
    }
    
    //MARK: - NEW API CALLS
    public static func sharedWithMeAsset(assetURI: String, flags: Bool = VCSFlagStates.flags, ownerInfo: Bool = VCSFlagStates.ownerInfo, thumbnail3D: Bool = VCSFlagStates.thumbnail3D, fileTypes: Bool = VCSFlagStates.fileType, sharingInfo: Bool = VCSFlagStates.sharingInfo, related: Bool = VCSFlagStates.related, branding: Bool = true) -> Future<VCSSharedWithMeAsset, Error> {
        return performRequest(route: APIRouter.sharedWithMeAsset(assetURI: assetURI, flags: flags, ownerInfo: ownerInfo, thumbnail3D: thumbnail3D, fileTypes: fileTypes, sharingInfo: sharingInfo, related: related, branding: branding))
    }
    
    public static func sharedWithMeAsset(assetResult: WebViewTaskAssetResult, related: Bool = VCSFlagStates.related, flags: Bool = VCSFlagStates.flags, ownerInfo: Bool = VCSFlagStates.ownerInfo, thumbnail3D: Bool = VCSFlagStates.thumbnail3D, fileType: Bool = VCSFlagStates.thumbnail3D, versioning: Bool = VCSFlagStates.versioning, sharingInfo: Bool = VCSFlagStates.sharingInfo) -> Future<VCSSharedWithMeAsset, Error> {
        
        let filePath = "/p:\(assetResult.path)/"
        var fileURI = "/restapi/public/v2/\(assetResult.storageType)/shared_with_me/file/o:\(assetResult.owner)/"
        if assetResult.isFolder {
            fileURI = "/restapi/public/v2/\(assetResult.storageType)/shared_with_me/folder/o:\(assetResult.owner)/"
        }
        let assetURI = fileURI.stringByAppendingPath(path: filePath)
        return APIClient.sharedWithMeAsset(assetURI: assetURI, flags: flags, ownerInfo: ownerInfo, thumbnail3D: thumbnail3D, fileTypes: fileType, sharingInfo: sharingInfo, related: related)
    }
    
    public static func linkSharedAsset(assetURI: String, flags: Bool = VCSFlagStates.flags, ownerInfo: Bool = VCSFlagStates.ownerInfo, thumbnail3D: Bool = VCSFlagStates.thumbnail3D, fileTypes: Bool = VCSFlagStates.fileType, sharingInfo: Bool = VCSFlagStates.sharingInfo, related: Bool = VCSFlagStates.related, versioning: Bool = VCSFlagStates.versioning) -> Future<VCSShareableLinkResponse, Error> {
        return performRequest(route: APIRouter.linkSharedAsset(assetURI: assetURI, flags: flags, ownerInfo: ownerInfo, thumbnail3D: thumbnail3D, fileTypes: fileTypes, sharingInfo: sharingInfo, related: related, versioning: versioning))
    }
    
    public static func markLinkAsVisited(assetURI: String?) -> Future<VCSEmptyResponse, Error> {
        guard let aURI = assetURI else { return Future(error: VCSNetworkError.parsingError("assetURI is nil")) }
        return performRequest(route: APIRouter.markLinkAsVisited(assetURI: aURI))
    }
    
    public static func folderAsset(assetURI: String, flags: Bool = VCSFlagStates.flags, ownerInfo: Bool = VCSFlagStates.ownerInfo, thumbnail3D: Bool = VCSFlagStates.thumbnail3D, fileTypes: Bool = VCSFlagStates.fileType, sharingInfo: Bool = VCSFlagStates.sharingInfo) -> Future<VCSFolderResponse, Error> {
        return performRequest(route: APIRouter.folderAsset(assetURI: assetURI, flags: flags, ownerInfo: ownerInfo, thumbnail3D: thumbnail3D, fileTypes: fileTypes, sharingInfo: sharingInfo))
    }
    
    public static func fileAsset(assetURI: String, related: Bool = VCSFlagStates.related, flags: Bool = VCSFlagStates.flags, ownerInfo: Bool = VCSFlagStates.ownerInfo, thumbnail3D: Bool = VCSFlagStates.thumbnail3D, fileType: Bool = VCSFlagStates.thumbnail3D, versioning: Bool = VCSFlagStates.versioning, sharingInfo: Bool = VCSFlagStates.sharingInfo) -> Future<VCSFileResponse, Error> {
        return performRequest(route: APIRouter.fileAsset(assetURI: assetURI, related: related, flags: flags, ownerInfo: ownerInfo, thumbnail3D: thumbnail3D, fileType: fileType, versioning: versioning, sharingInfo: sharingInfo))
    }
    
    public static func fileAsset(assetResult: WebViewTaskAssetResult, related: Bool = VCSFlagStates.related, flags: Bool = VCSFlagStates.flags, ownerInfo: Bool = VCSFlagStates.ownerInfo, thumbnail3D: Bool = VCSFlagStates.thumbnail3D, fileType: Bool = VCSFlagStates.thumbnail3D, versioning: Bool = VCSFlagStates.versioning, sharingInfo: Bool = VCSFlagStates.sharingInfo) -> Future<VCSFileResponse, Error> {
        
        let filePath = "/p:\(assetResult.path)/"
        let fileURI = "/restapi/public/v2/\(assetResult.storageType)/file/o:\(assetResult.owner)/"
        let assetURI = fileURI.stringByAppendingPath(path: filePath)
        return performRequest(route: APIRouter.fileAsset(assetURI: assetURI, related: related, flags: flags, ownerInfo: ownerInfo, thumbnail3D: thumbnail3D, fileType: fileType, versioning: versioning, sharingInfo: sharingInfo))
    }
    
    public static func postGenericJob(jobData: GenericJobRequest) -> Future<VCSJobResponse, Error> {
        return performRequest(route: APIRouter.genericJob(data: jobData))
    }
    
    public static func ssoTempUserToken(loginSettings: VCSLoginSettingsResponse?) -> Future<VCSSSOTempToken, Error> {
        guard let lSettings = loginSettings else { return Future(error: VCSNetworkError.parsingError("LoginSettings is nil")) }
        return performRequest(route: APIRouter.ssoTempUserToken(loginSettings: lSettings))
    }
    
    public static func linkDetailsData(link: String?) -> Future<LinkDetailsData, Error> {
        guard let l = link else { return Future(error: VCSNetworkError.parsingError("link is empty")) }
        return performRequest(route: APIRouter.linkDetailsData(link: l))
    }
    
    public static func unshare(assetURI: String) -> Future<VCSEmptyResponse, Error> {
        return performRequest(route: APIRouter.unshare(assetURI: assetURI))
    }
    
    public static func mountFolder(storageType: String, ownerLogin: String, prefix: String, mountValue: Bool) -> Future<VCSMountFolderResponse, Error> {
        return performRequest(route: APIRouter.mountFolder(storageType: storageType, ownerLogin: ownerLogin, prefix: prefix, mountValue: mountValue))
    }
    
    public static func getCurrentUserBranding() -> Future<VCSSharedAssetBrandingResponseWrapper, Error> {
        return performRequest(route: APIRouter.branding)
    }
    
    //MARK: - DOWNLOAD
    // key here is file.id. The files that we compare are not actually the same object for some reason
    public static var downloads = [String : Download]()
    public static var uploads = [String : DataRequest]()
    
    /** Progress delegate calls are handled internally.
     */
    public class func download(file: VCSFileResponse) -> Future<String, Error> {
        return Future<String, Error> { (completion) in
            let download = Download(parent: file)
            self.downloads[file.rID] = download
            guard download.files.count > 0 else {
                completion(.failure(VCSNetworkError.GenericException("APIClient - download - download.files is 0")))
                return
            }
            download.files.forEach { (downloadFile) in
                let destination: DownloadRequest.Destination = { _, _ in
                    let fileUUID = UUID().uuidString
                    let fileURL = FileManager.downloadPath(uuidString: fileUUID, pathExtension: downloadFile.name.pathExtension)
                    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                }
                
                guard let downloadURL = URL(string: VCSServer.default.serverURLString.stringByAppendingPath(path: downloadFile.downloadURLString)) else {
                    DDLogError("Error constructing download URL")
                    return
                }
                
                if (!download.hasStarted) {
                    NotificationCenter.postDownloadNotification(model: file, progress: ProgressValues.Started.rawValue)
                    download.hasStarted = true
                }
                
                var alamofireDownloadHeaders = Alamofire.HTTPHeaders([HTTPHeaderField.acceptEncoding.rawValue: "identity"])
                if let oauth2 = APIClient.oauth2Client, let apiToken = oauth2.accessToken {
                    let authHeaderValue = oauth2.clientConfig.headerTokenPrefix + " " + apiToken
                    alamofireDownloadHeaders = Alamofire.HTTPHeaders([HTTPHeaderField.acceptEncoding.rawValue: "identity", HTTPHeaderField.authentication.rawValue: authHeaderValue])
                }
                
                let downloadRequest = Alamofire.AF.download(
                    downloadURL,
                    method: .get,
                    parameters: ["download" : "on"],
                    encoding: URLEncoding.default,
                    headers: alamofireDownloadHeaders,
                    to: destination)
                
                downloadRequest.downloadProgress { (progress: Progress) in
                    download.update(progress: progress.fractionCompleted, forFile: downloadFile)
                    NotificationCenter.postDownloadNotification(model: file, progress: download.totalProgress)
                    DDLogInfo("Downloading \(downloadFile.name): \(progress.fractionCompleted)")
                }
                downloadRequest.response { (dataResponse: AFDownloadResponse) in
                    switch dataResponse.result {
                    case .success(let destURL):
                        if let destURLValue = destURL {
                            let localFile = LocalFile(name: downloadFile.name, uuid: destURLValue.toLocalUUID)
                            downloadFile.setLocalFile(localFile)
                            download.update(progress: 1, forFile: downloadFile)
                            NotificationCenter.postDownloadNotification(model: file, progress: download.totalProgress)
                            
                            if (download.isFinished) {
                                downloadFile.loadLocalFiles()
                                completion(.success(localFile.uuid))
                                NotificationCenter.postDownloadNotification(model: file, progress: ProgressValues.Finished.rawValue)
                            }
                        } else {
                            NotificationCenter.postDownloadNotification(model: file, progress: ProgressValues.Finished.rawValue)
                            completion(.failure(VCSNetworkError.GenericException("File was not found on disk")))
                        }
                    case .failure(let error):
                        DDLogInfo("APIClient.download - failure")
                        NetworkLogger.log("##### VCSNetwork error:\t\(dataResponse)")
                        NetworkLogger.log("##### VCSNetwork error code:\t\(dataResponse.response?.statusCode ?? 0)")
                        NetworkLogger.log("##### VCSNetwork error URL:\t\(dataResponse.request?.url?.absoluteString ?? "")")
                        
                        NotificationCenter.postDownloadNotification(model: file, progress: ProgressValues.Finished.rawValue)
                        completion(.failure(error))
                    }
                    self.downloads[file.rID] = nil
                }
                
                downloadRequest.validate()
                
                download.add(request: downloadRequest, for: downloadFile)
            }
        }
    }
    
    //END - NEW API CALLS
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public static func getDateFromUploadResponse(_ response: HTTPURLResponse?, data: Data?) -> Date {
        var result = Date()
        
        if let date: Date = response?.allHeaderFields["last_modified"] as? Date {
            result = date
        }
        
        if let data: Data = data,
            let json: [String : Any] = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String : Any],
            let dateString = json["server_modified"] as? String,
            let resultDate = dateString.dateFromISO8601 {
            result = resultDate
        }
        
        //s3 && Google
        if let dateString = response?.allHeaderFields["Date"] as? String,
            let resultDate = dateString.dateFromRFC1123 {
            result = resultDate
        }
        
        return result
    }
}

public class Download {
    
    public let files: [VCSFileResponse]
    private var progress = [VCSFileResponse : Double]()
    public let parent: FileAsset
    var hasStarted = false
    private var requests = [VCSFileResponse : DownloadRequest]()
    
    var totalProgress: Double { return progress.values.reduce(0.0, +) / Double(self.files.count) }
    
    var isFinished: Bool { return totalProgress == 1.0 }
    
    init(parent: VCSFileResponse) {
        self.parent = parent
        self.files = parent.filesForDownload
        self.files.forEach { progress[$0] = 0.0 }
    }
    
    func update(progress: Double, forFile file: VCSFileResponse) {
        self.progress[file] = progress
    }
    
    func add(request: DownloadRequest, for file: VCSFileResponse) {
        self.requests[file] = request
    }
    
    private func delete(file: VCSFileResponse) {
        guard file.isAvailableOnDevice else { return }
        file.setLocalFile(nil)
    }
    
    /** Cancels the ongoing requests and deletes the downloaded files.
     */
    public func cancel() {
        self.requests.values.forEach { $0.cancel() }
        self.requests.keys.forEach { self.delete(file: $0) }
        APIClient.downloads[parent.rID] = nil
    }
}
