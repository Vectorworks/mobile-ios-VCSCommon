import Foundation
import Alamofire
import WebKit
import CocoaLumberjackSwift

public enum APIRouter: URLRequestConvertible {

    case loginSettings
    case vcsUser
    case currentAccount
    case listFolder(folderURI: String) // delete

    case createFolder(storage: StorageType, folderURI: String)
    case folderStats(owner: String, folderURI: String)
    case listStorage
    case getStoragePagesList(storagePagesURI: String)

    case sendFeedback(feedbackData: FeedbackRequest)
    case listSharedWithMe
    case listSharedFolder
    case processFile(filePrefix: String, storageType: String, owner: String, jobType: String)
    case processPhotogram(jobData: PhotogramJobRequest)
    case fileData(owner: String, storage: String, filePrefix: String, updateFromStorage: Bool, googleDriveID: String?, googleDriveVerID: String?)
    case patchFile(owner: String, storage: String, filePrefix: String, updateFromStorage: Bool, data: Data, googleDriveID: String? = nil, googleDriveVerID: String? = nil)
    case getUploadURL(owner: String, storage: String, filePrefix: String, size: Int)
    case uploadData(uploadURL: VCSUploadURL, uploadData: Data)
    case uploadFileURL(uploadURL: VCSUploadURL)
    case deleteResource(resourceURL: String)
    case deleteAsset(asset: Asset)
    case job(jobID: String)
    case listJobs(initialRequest: Bool)
    case unssenNotificationsIDs
    case clearNotifications(IDsHolder: ClearNotificationHolder)
    case genericJob(data: GenericJobRequest)

    // NEW API CALLS
    case sharedWithMeAsset(assetURI: String, flags: Bool, ownerInfo: Bool, thumbnail3D: Bool, fileTypes: Bool, sharingInfo: Bool, related: Bool, branding: Bool)
    case sharedWithMeFileInfo(rID: String, flags: Bool, ownerInfo: Bool, thumbnail3D: Bool, fileTypes: Bool, sharingInfo: Bool, related: Bool, branding: Bool)
    case sharedWithMeFolderInfo(rID: String, flags: Bool, ownerInfo: Bool, thumbnail3D: Bool, fileTypes: Bool, sharingInfo: Bool, related: Bool, branding: Bool)
    case linkSharedAsset(assetURI: String, flags: Bool, ownerInfo: Bool, thumbnail3D: Bool, fileTypes: Bool, sharingInfo: Bool, related: Bool, versioning: Bool)
    case markLinkAsVisited(assetURI: String)
    case folderAsset(assetURI: String, flags: Bool, ownerInfo: Bool, thumbnail3D: Bool, fileTypes: Bool, sharingInfo: Bool)
    case fileAsset(assetURI: String, related: Bool, flags: Bool, ownerInfo: Bool, thumbnail3D: Bool, fileType: Bool, versioning: Bool, sharingInfo: Bool)
    case folderInfo(rID: String, flags: Bool, ownerInfo: Bool, thumbnail3D: Bool, fileTypes: Bool, sharingInfo: Bool)
    case fileInfo(rID: String, related: Bool, flags: Bool, ownerInfo: Bool, thumbnail3D: Bool, fileType: Bool, versioning: Bool, sharingInfo: Bool)
    case sharedFileAsset(assetURI: String, related: Bool, flags: Bool, ownerInfo: Bool, thumbnail3D: Bool, fileType: Bool, versioning: Bool, sharingInfo: Bool)
    case ssoTempUserToken(loginSettings: VCSLoginSettingsResponse)
    case linkDetailsData(link: String)
    case unshare(assetURI: String)
    case mountFolder(storageType: String, ownerLogin: String, prefix: String, mountValue: Bool)
    case branding
    case socketPreSignedUri
    case listPresentations(limit: Int, offset: Int)
    case presentationDownload(presentationUIID: String)
    case listVCDOCComments(fileOwner: String, storageType: String, storagePath: String)
    case sendVCDOCReply(replyData: VCSVWViewerReplyRequest)
    case getTrustedAccounts
    case addVCDOCComment(commentData: VCSVWViewerAddCommentRequest)
    case search(query: String, storageType: String?, sharedWithMe: Bool)

    // MARK: - requestURL
    private var requestURL: VCSRequestURL {
        switch self {
        case .loginSettings:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v08)
        case .vcsUser:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v02)
        case .currentAccount:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v2)
        case .listFolder:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.none)
        case .createFolder:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v2)
        case .folderStats:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.none)
        case .listStorage:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v2)
        case .getStoragePagesList:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.none)
        case .sendFeedback:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v1)
        case .listSharedWithMe:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v2)
        case .listSharedFolder:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v2)
        case .processFile:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v1)
        case .processPhotogram:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v1)
        case .fileData:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v2)
        case .patchFile:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v2)
        case .getUploadURL:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v2)
        case .uploadData(let uploadURL, _):
            return VCSRequestURL(vcsServer: VCSServer(server: uploadURL.url), APIVersion: VCSAPIVersion.none)
        case .uploadFileURL(let uploadURL):
            return VCSRequestURL(vcsServer: VCSServer(server: uploadURL.url), APIVersion: VCSAPIVersion.none)
        case .deleteResource:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.none)
        case .deleteAsset:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v2)
        case .job:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v1)
        case .listJobs:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v1)
        case .unssenNotificationsIDs:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v1)
        case .clearNotifications:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v1)
        case .genericJob:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v1)

            // NEW API CALLS
        case .sharedWithMeAsset:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.none)
        case .sharedWithMeFileInfo:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v2)
        case .sharedWithMeFolderInfo:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v2)
        case .linkSharedAsset:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.none)
        case .markLinkAsVisited:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.none)
        case .folderAsset:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.none)
        case .fileAsset:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.none)
        case .folderInfo:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v2)
        case .fileInfo:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v2)
        case .sharedFileAsset:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.none)
        case .ssoTempUserToken(let loginSettings):
            let ssoServer = VCSServer(server: loginSettings.loginServer)
            return VCSRequestURL(vcsServer: ssoServer, APIVersion: VCSAPIVersion.none)
        case .linkDetailsData:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v1)
        case .unshare:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.none)
        case .mountFolder:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v2)
        case .branding:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v1)
        case .socketPreSignedUri:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v1)
        case .listPresentations:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v1)
        case .presentationDownload:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v1)
        case .listVCDOCComments:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v2)
        case .sendVCDOCReply:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v1)
        case .getTrustedAccounts:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v2)
        case .addVCDOCComment:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v1)
        case .search:
            return VCSRequestURL(vcsServer: VCSServer.default, APIVersion: VCSAPIVersion.v2)
        }
    }

    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .createFolder:
            return .put
        case .processFile:
            return .post
        case .processPhotogram:
            return .post
        case .patchFile:
            return .patch
        case .uploadData(let uploadURL, _):
            if let customMethod = uploadURL.uploadMethod {
                return HTTPMethod(rawValue: customMethod)
            }
            return .put
        case .uploadFileURL(let uploadURL):
            if let customMethod = uploadURL.uploadMethod {
                return HTTPMethod(rawValue: customMethod)
            }
            return .put
        case .deleteResource:
            return .delete
        case .deleteAsset:
            return .delete
        case .clearNotifications:
            return.post
        case .sendFeedback:
            return .post
        case .genericJob:
            return .post
        case .ssoTempUserToken:
            return .post
        case .linkDetailsData:
            return .post
        case .unshare:
            return .delete
        case .mountFolder:
            return .put
        case .sendVCDOCReply:
            return .post
        case .addVCDOCComment:
            return .post
        default:
            return .get
        }
    }

    // MARK: - Path
    private var path: String {
        switch self {
        case .loginSettings:
            return "/login_settings/"
        case .vcsUser:
            return "/user/"
        case .currentAccount:
            return "/current-account/"
        case .listFolder(let folderURI):
            return folderURI
        case .createFolder(let storage, let folderURI):
            var result = storage.rawValue.stringByAppendingPath(path: "/folder/")
            result = result.stringByAppendingPath(path: folderURI)
            return result.VCSNormalizedURLString()
        case .processFile:
            return "/jobs/"
        case .processPhotogram:
            return "/jobs/"
        case .folderStats(let owner, let folderURI):
            return self.modStatsFolderURI(owner: owner, folderURI: folderURI)
        case .listStorage:
            return "/storage/"
        case .getStoragePagesList(let storagePagesURI):
            return storagePagesURI
        case .sendFeedback:
            return "/feedback/"
        case .listSharedWithMe:
            return "/__all__/shared_with_me/"
        case .listSharedFolder:
            return "/__all__/shared_asset/"
        case .fileData(let owner, let storage, let filePrefix, _, let googleDriveID, let googleDriveVerID):
            var result = storage.stringByAppendingPath(path: "/file/")
            if !result.contains("o:") {
                result = result.stringByAppendingPath(path: "/o:\(owner)/")
            }
            let filePath = "/p:\(filePrefix)/"
            result = result.stringByAppendingPath(path: filePath)
            if !result.contains("id:"), !result.contains("v:"), let googleDriveIDValue = googleDriveID, let googleDriveVerIDValue = googleDriveVerID {
                result = result.stringByAppendingPath(path: "/id:\(googleDriveIDValue)/")
                result = result.stringByAppendingPath(path: "/v:\(googleDriveVerIDValue)/")
            }
            return result
        case .patchFile(let owner, let storage, let filePrefix, _, _, let googleDriveID, let googleDriveVerID):
            var result = storage.stringByAppendingPath(path: "/file/")
            if !result.contains("o:") {
                result = result.stringByAppendingPath(path: "/o:\(owner)/")
            }
            let filePath = "/p:\(filePrefix)/"
            result = result.stringByAppendingPath(path: filePath)
            if !result.contains("id:"), !result.contains("v:"), let googleDriveIDValue = googleDriveID, let googleDriveVerIDValue = googleDriveVerID {
                result = result.stringByAppendingPath(path: "/id:\(googleDriveIDValue)/")
                result = result.stringByAppendingPath(path: "/v:\(googleDriveVerIDValue)/")
            }
            return result
        case .getUploadURL(let owner, let storage, let filePrefix, let size):
            var result = storage.stringByAppendingPath(path: "/file/:upload_url/")
            if !result.contains("o:") {
                result = result.stringByAppendingPath(path: "/o:\(owner)/")
            }
            let filePath = "/p:\(filePrefix)/"
            result = result.stringByAppendingPath(path: filePath)
            let size = "/s:\(size)/"
            result = result.stringByAppendingPath(path: size)
            return result
        case .uploadData:
            return ""
        case .uploadFileURL:
            return ""
        case .deleteResource(let resourceURL):
            var itemResourceURL = resourceURL
            if let regex = try? NSRegularExpression(pattern: "/v:.*\\/", options: .caseInsensitive) {
                itemResourceURL = regex.stringByReplacingMatches(in: itemResourceURL, options: .reportCompletion, range: NSRange(location: 0, length: itemResourceURL.count), withTemplate: "")
            }
            return itemResourceURL.VCSNormalizedURLString()
        case .deleteAsset(let asset):
            let fileType = asset.isFolder ? "folder" : "file"
            let result = "/\(asset.storageTypeString)/\(fileType)/id:\(asset.resourceID)/"
            return result
        case .job(let jobID):
            let result = "/jobs/".stringByAppendingPath(path: jobID)
            return result.VCSNormalizedURLString()
        case .listJobs:
            return "/jobs/"
        case .unssenNotificationsIDs:
            return "/unseen/"
        case .clearNotifications:
            return "/clear_unseen/"
        case .genericJob:
            return "/jobs/"

            // NEW API CALLS
        case .sharedWithMeAsset(let assetURI, _, _, _, _, _, _, _):
            return assetURI
        case .sharedWithMeFileInfo(let rID, _, _, _, _, _, _, _):
            return "/_/shared_with_me/file/id:\(rID)/"
        case .sharedWithMeFolderInfo(let rID, _, _, _, _, _, _, _):
            return "/_/shared_with_me/folder/id:\(rID)/"
        case .linkSharedAsset(let assetURI, _, _, _, _, _, _, _):
            return assetURI
        case .markLinkAsVisited(let assetURI):
            return assetURI
        case .folderAsset(let assetURI, _, _, _, _, _):
            return assetURI
        case .fileAsset(let assetURI, _, _, _, _, _, _, _):
            return assetURI
        case .folderInfo(let rID, _, _, _, _, _):
            return "/_/folder/id:\(rID)/"
        case .fileInfo(let rID, _, _, _, _, _, _, _):
            return "/_/file/id:\(rID)/"
        case .sharedFileAsset(let assetURI, _, _, _, _, _, _, _):
            return assetURI.replacingOccurrences(of: "/restapi/public/v2/s3/file", with: "/restapi/public/v2/s3/shared_file")
        case .ssoTempUserToken:
            return "/api/v2/public/users/@current/api-token/@temp/"
        case .linkDetailsData:
            return "/link-summary/"
        case .unshare(let assetURI):
            return assetURI
        case .mountFolder(let storageType, let ownerLogin, let prefix, _):
            return "/\(storageType)/shared_with_me/folder/:mount/o:\(ownerLogin)/p:\(prefix)/"
        case .branding:
            return "/branding/"
        case .socketPreSignedUri:
            return "/messenger/presigned-uri/"
        case .listPresentations:
            return "/iboards/"
        case .presentationDownload(let presentationUIID):
            return "/iboards/\(presentationUIID)/download/"
        case .listVCDOCComments(let fileOwner, let storageType, let storagePath):
            return "\(storageType.lowercased())/file/:comments/o:\(fileOwner)/p:\(storagePath)/"
        case .sendVCDOCReply:
            return "/reply/"
        case .getTrustedAccounts:
            return "/trusted-accounts/"
        case .addVCDOCComment:
            return "/comment/"
        case .search(_, let storageType, let sharedWithMe):
            if sharedWithMe {
                return "__all__/search/"
            } else {
                return "\(storageType!)/search/"
            }
        }
    }

    private func modStatsFolderURI(owner: String, folderURI: String) -> String {
        let components = folderURI.components(separatedBy: "/o:")
        guard let pathPrefix = components.first else { return folderURI }
        guard let pathSuffix = components.last else { return folderURI }
        var result = pathPrefix.stringByAppendingPath(path: "/:stats/")
        if components.count > 1 {
            result = result.stringByAppendingPath(path: "/o:\(pathSuffix)")
        } else {
            result = result.stringByAppendingPath(path: "/o:\(owner)/")
        }

        return result
    }

    // MARK: - Parameters
    private var bodyParameters: Parameters? {
        switch self {
        case .processFile(let filePrefix, let storageType, let owner, let jobType):
            let fileVersion = [K.APIParameterKey.jobs.provider: storageType,
                               K.APIParameterKey.jobs.path: filePrefix,
                               K.APIParameterKey.jobs.owner: owner]
            return [K.APIParameterKey.jobs.fileVersion: fileVersion,
                    K.APIParameterKey.jobs.jobType: jobType]
        case .processPhotogram(let jobData):
            return jobData.asDictionary()
        case .sendFeedback(let feedbackData):
            return feedbackData.asDictionary()
        case .genericJob(let jobData):
            return jobData.asDictionary()
        case .linkDetailsData(let link):
            return [K.APIParameterKey.linkDetailsData.url: link]
        case .clearNotifications(let IDsHolder):
            return [ClearNotificationHolder.CodingKeys.sequenceNumbers.stringValue: IDsHolder.sequenceNumbers]
        case .mountFolder(_, _, _, let mountValue):
            let actionValue = mountValue ? "mount" : "unmount"
            return [K.APIParameterKey.mountFolder.action: actionValue]
        case .sendVCDOCReply(let replyData):
            return replyData.asDictionary()
        case .addVCDOCComment(let commentData):
            return commentData.asDictionary()
        default:
            return nil
        }
    }

    private var bodyData: Data? {
        switch self {
        case .patchFile(_, _, _, _, let data, _, _):
            return data
        case .uploadData(_, let uploadData):
            return uploadData
        default:
            return nil
        }
    }

    private var queryParameters: [URLQueryItem]? {
        switch self {
        case .getStoragePagesList:
            let querySharedPaths = URLQueryItem(name: "fields", value: "(shared_paths)")
            return [querySharedPaths]
        case .listSharedWithMe:
            let queryItemRelated = URLQueryItem(name: "related", value: "on")
            let queryItemLimit = URLQueryItem(name: "limit", value: "300")

            var result: [URLQueryItem] = [queryItemRelated, queryItemLimit]

            if let queryItemFields = APIRouter.sharedWithMeAsset(assetURI: "shared_with_me/folder/o:", flags: true, ownerInfo: true, thumbnail3D: true, fileTypes: true, sharingInfo: true, related: true, branding: true).queryParameters {
                result.append(contentsOf: queryItemFields)
            }

            return result
        case .listSharedFolder:
            let queryItemRelated = URLQueryItem(name: "related", value: "on")
            let queryItemOrdering = URLQueryItem(name: "ordering", value: "name")
            let queryItemLimit = URLQueryItem(name: "limit", value: "300")
            let queryItemFields = URLQueryItem(name: "fields", value: "(asset.flags,asset.owner_info.mount_point,asset.thumbnail_3d,asset.file_type,asset.sharing_info,asset.sharing_info.link_visits_count,asset.sharing_info.shared_with,asset.sharing_info.last_share_date,asset.sharing_info.allow_comments)")
            return [queryItemRelated, queryItemOrdering, queryItemLimit, queryItemFields]
        case .fileData(_, _, _, let updateFromStorage, _, _):
            let queryItemUpdate = URLQueryItem(name: "update_from_storage", value: "true")
            let queryItemRelated = URLQueryItem(name: "related", value: "on")
            let queryItemFileType = URLQueryItem(name: "fields", value: "(flags,owner_info.mount_point,thumbnail_3d,file_type,related.file_type,sharing_info,sharing_info.link_visits_count,sharing_info.shared_with,sharing_info.last_share_date,sharing_info.allow_comments)")
            let result = updateFromStorage ? [queryItemUpdate, queryItemRelated, queryItemFileType] : [queryItemRelated, queryItemFileType]
            return result
        case .patchFile(_, _, _, let updateFromStorage, _, _, _):
            let queryItemUpdate = URLQueryItem(name: "update_from_storage", value: "true")
            let result = updateFromStorage ? [queryItemUpdate] : []
            return result
        case .job:
            let queryItemFields = URLQueryItem(name: "fields", value: "(output_location_owner,options.src_file_info,-options.ref_file_versions)")
            return [queryItemFields]
        case .listJobs(let initialRequest):
            var result: [URLQueryItem]?
            if initialRequest {
                let queryItemCurrent = URLQueryItem(name: "current", value: "job_type__in=export_pdf,publish,distill,generic,photogram")
                let queryItemLimit = URLQueryItem(name: "limit", value: "25")
                let queryItemFields = URLQueryItem(name: "fields", value: "(output_location_owner,options.src_file_info,-options.ref_file_versions)")
                result = [queryItemCurrent, queryItemLimit, queryItemFields]
            }
            return result
        case .unssenNotificationsIDs:
            let queryItemClient = URLQueryItem(name: "client", value: "ios")
            return [queryItemClient]
        case .clearNotifications:
            let queryItemClient = URLQueryItem(name: "client", value: "ios")
            return [queryItemClient]

            // NEW API CALLS
        case .linkSharedAsset(_, let flags, let ownerInfo, let thumbnail3D, let fileTypes, let sharingInfo, let related, let versioning):
            var result: [URLQueryItem] = []
            var fields: [String] = []

            if flags {
                fields.append("asset.flags")
                fields.append("asset.files.flags")
                fields.append("asset.subfolders.flags")
            }

            if ownerInfo {
                fields.append("asset.owner_info.mount_point")
                fields.append("asset.files.owner_info.mount_point")
                fields.append("asset.subfolders.owner_info.mount_point")
            }

            if thumbnail3D {
                fields.append("asset.thumbnail_3d")
                fields.append("asset.files.thumbnail_3d")
            }

            if fileTypes {
                fields.append("asset.file_type")
                fields.append("asset.files.file_type")
            }

            if sharingInfo {
                fields.append("asset.sharing_info")
                fields.append("asset.sharing_info.link_visits_count")
                fields.append("asset.sharing_info.shared_with")
                fields.append("asset.sharing_info.last_share_date")
                fields.append("asset.sharing_info.allow_comments")
                fields.append("asset.files.sharing_info")
                fields.append("asset.files.sharing_info.link_visits_count")
                fields.append("asset.files.sharing_info.shared_with")
                fields.append("asset.files.sharing_info.last_share_date")
                fields.append("asset.files.sharing_info.allow_comments")
                fields.append("asset.subfolders.sharing_info")
                fields.append("asset.subfolders.sharing_info.link_visits_count")
                fields.append("asset.subfolders.sharing_info.shared_with")
                fields.append("asset.subfolders.sharing_info.last_share_date")
                fields.append("asset.subfolders.sharing_info.allow_comments")
            }

            if fields.count > 0 {
                let value = "(" + fields.joined(separator: ",") + ")"
                let queryItemFields = URLQueryItem(name: "fields", value: value)
                result.append(queryItemFields)
            }

            if related {
                let queryItemRelated = URLQueryItem(name: "related", value: "on")
                result.append(queryItemRelated)
            }

            if versioning {
                let queryItemVersioning = URLQueryItem(name: "versioning", value: "on")
                result.append(queryItemVersioning)
            }

            return result
        case .folderAsset(_, let flags, let ownerInfo, let thumbnail3D, let fileTypes, let sharingInfo),
                .folderInfo(_, let flags, let ownerInfo, let thumbnail3D, let fileTypes, let sharingInfo):
            var result: [URLQueryItem] = []
            var fields: [String] = []

            if flags {
                fields.append("flags")
                fields.append("files.flags")
                fields.append("subfolders.flags")
            }

            if ownerInfo {
                fields.append("owner_info.mount_point")
                fields.append("files.owner_info.mount_point")
                fields.append("subfolders.owner_info.mount_point")
            }

            if thumbnail3D {
                fields.append("files.thumbnail_3d")
            }

            if fileTypes {
                fields.append("files.file_type")
            }

            if sharingInfo {
                fields.append("sharing_info")
                fields.append("sharing_info.link_visits_count")
                fields.append("sharing_info.shared_with")
                fields.append("sharing_info.last_share_date")
                fields.append("sharing_info.allow_comments")
                fields.append("files.sharing_info")
                fields.append("files.sharing_info.link_visits_count")
                fields.append("files.sharing_info.shared_with")
                fields.append("files.sharing_info.last_share_date")
                fields.append("files.sharing_info.allow_comments")
                fields.append("subfolders.sharing_info")
                fields.append("subfolders.sharing_info.link_visits_count")
                fields.append("subfolders.sharing_info.shared_with")
                fields.append("subfolders.sharing_info.last_share_date")
                fields.append("subfolders.sharing_info.allow_comments")
            }

            if fields.count > 0 {
                let value = "(" + fields.joined(separator: ",") + ")"
                let queryItemFields = URLQueryItem(name: "fields", value: value)
                result.append(queryItemFields)
            }

            return result
        case .fileAsset(_, let related, let flags, let ownerInfo, let thumbnail3D, let fileType, let versioning, let sharingInfo),
                .sharedFileAsset(_, let related, let flags, let ownerInfo, let thumbnail3D, let fileType, let versioning, let sharingInfo),
                .fileInfo(_, let related, let flags, let ownerInfo, let thumbnail3D, let fileType, let versioning, let sharingInfo):
            var result: [URLQueryItem] = []

            if related {
                let queryItemRelated = URLQueryItem(name: "related", value: "on")
                result.append(queryItemRelated)
            }

            if versioning {
                let queryItemVersioning = URLQueryItem(name: "versioning", value: "on")
                result.append(queryItemVersioning)
            }

            var fields: [String] = []

            if flags {
                fields.append("flags")
            }

            if ownerInfo {
                fields.append("owner_info.mount_point")
            }

            if thumbnail3D {
                fields.append("thumbnail_3d")
            }

            if fileType {
                fields.append("file_type")
            }

            if sharingInfo {
                fields.append("sharing_info")
                fields.append("sharing_info.link_visits_count")
                fields.append("sharing_info.shared_with")
                fields.append("sharing_info.last_share_date")
                fields.append("sharing_info.allow_comments")
            }

            if fields.count > 0 {
                let value = "(" + fields.joined(separator: ",") + ")"
                let queryItemFields = URLQueryItem(name: "fields", value: value)
                result.append(queryItemFields)
            }

            return result
        case .sharedWithMeAsset(let assetURI, let flags, let ownerInfo, let thumbnail3D, let fileTypes, let sharingInfo, let related, let branding):
            let isFolder = assetURI.contains("shared_with_me/folder/o:")

            var result: [URLQueryItem] = []
            var fields: [String] = []

            if related {
                let queryItemRelated = URLQueryItem(name: "related", value: "on")
                result.append(queryItemRelated)
            }

            if flags {
                fields.append("asset.flags")

                if isFolder {
                    fields.append("asset.files.flags")
                    fields.append("asset.subfolders.flags")
                }
            }

            if ownerInfo {
                fields.append("asset.owner_info.mount_point")

                if isFolder {
                    fields.append("asset.files.owner_info.mount_point")
                    fields.append("asset.subfolders.owner_info.mount_point")
                }
            }

            if thumbnail3D {
                if isFolder {
                    fields.append("asset.files.thumbnail_3d")
                } else {
                    fields.append("asset.thumbnail_3d")
                }
            }

            if fileTypes {
                if isFolder {
                    fields.append("asset.files.file_type")
                } else {
                    fields.append("asset.file_type")
                }
            }

            if sharingInfo {
                fields.append("asset.sharing_info")
                fields.append("asset.sharing_info.link_visits_count")
                fields.append("asset.sharing_info.shared_with")
                fields.append("asset.sharing_info.last_share_date")
                fields.append("asset.sharing_info.allow_comments")

                if isFolder {
                    fields.append("asset.files.sharing_info")
                    fields.append("asset.files.sharing_info.link_visits_count")
                    fields.append("asset.files.sharing_info.shared_with")
                    fields.append("asset.files.sharing_info.last_share_date")
                    fields.append("asset.files.sharing_info.allow_comments")
                    fields.append("asset.subfolders.sharing_info")
                    fields.append("asset.subfolders.sharing_info.link_visits_count")
                    fields.append("asset.subfolders.sharing_info.shared_with")
                    fields.append("asset.subfolders.sharing_info.last_share_date")
                    fields.append("asset.subfolders.sharing_info.allow_comments")
                }
            }

            if branding {
                fields.append("branding")
            }

            if fields.count > 0 {
                let value = "(" + fields.joined(separator: ",") + ")"
                let queryItemFields = URLQueryItem(name: "fields", value: value)
                result.append(queryItemFields)
            }

            return result
        case .sharedWithMeFileInfo(_, let flags, let ownerInfo, let thumbnail3D, let fileTypes, let sharingInfo, let related, let branding):
            return APIRouter.sharedWithMeAsset(assetURI: "shared_with_me", flags: flags, ownerInfo: ownerInfo, thumbnail3D: thumbnail3D, fileTypes: fileTypes, sharingInfo: sharingInfo, related: related, branding: branding).queryParameters
        case .sharedWithMeFolderInfo(_, let flags, let ownerInfo, let thumbnail3D, let fileTypes, let sharingInfo, let related, let branding):
            return APIRouter.sharedWithMeAsset(assetURI: "shared_with_me/folder/o:", flags: flags, ownerInfo: ownerInfo, thumbnail3D: thumbnail3D, fileTypes: fileTypes, sharingInfo: sharingInfo, related: related, branding: branding).queryParameters
        case .ssoTempUserToken:
            var result: [URLQueryItem] = []
            let queryItemRelated = URLQueryItem(name: "system", value: "iOSNomad")
            result.append(queryItemRelated)
            return result
        case .socketPreSignedUri:
            var result: [URLQueryItem] = []
            let queryItemAppName = URLQueryItem(name: "app_name", value: "nomad")
            result.append(queryItemAppName)
            return result
        case .listPresentations(let limit, let offset):
            var result: [URLQueryItem] = []
            let queryItemLimit = URLQueryItem(name: "limit", value: "\(limit)")
            result.append(queryItemLimit)
            if offset != .zero {
                let queryItemOffset = URLQueryItem(name: "offset", value: "\(offset)")
                result.append(queryItemOffset)
            }
            return result
        case .presentationDownload:
            var result: [URLQueryItem] = []
            let queryItemOsMac = URLQueryItem(name: "os", value: "mac")
            result.append(queryItemOsMac)
            return result
        case .search(let query, _, let sharedWithMe):
            var result: [URLQueryItem] = []
            let queryItemQ = URLQueryItem(name: "q", value: query)
            if sharedWithMe {
                let queryItemSharedWithMe = URLQueryItem(name: "sharedWithMe", value: "true")
                result.append(queryItemSharedWithMe)
                let queryItemFields: URLQueryItem = URLQueryItem(name: "fields", value: "(branding)")
                result.append(queryItemFields)
            }
            result.append(queryItemQ)
            return result
        default:
            return nil
        }
    }

    func changeHeaders(_ urlRequest: inout URLRequest) {
        switch self {
        case .uploadData(let uploadURL, _):
            urlRequest.setValue(uploadURL.contentType, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
            urlRequest.setValue("\(uploadURL.contentLength)", forHTTPHeaderField: HTTPHeaderField.contentLength.rawValue)

            if let dropboxAPIPathRoot = uploadURL.headers.dropboxAPIPathRoot {
                urlRequest.setValue(dropboxAPIPathRoot, forHTTPHeaderField: Headers.CodingKeys.dropboxAPIPathRoot.rawValue)
            }

            if let dropboxAPIArg = uploadURL.headers.dropboxAPIArg {
                urlRequest.setValue(dropboxAPIArg, forHTTPHeaderField: Headers.CodingKeys.dropboxAPIArg.rawValue)
            }

            if let authorization = uploadURL.headers.authorization {
                urlRequest.setValue(authorization, forHTTPHeaderField: Headers.CodingKeys.authorization.rawValue)
            }

            if let contentLength = uploadURL.headers.contentLength {
                urlRequest.setValue("\(contentLength)", forHTTPHeaderField: Headers.CodingKeys.contentLength.rawValue)
            }
            if let contentType = uploadURL.headers.contentType {
                urlRequest.setValue(contentType, forHTTPHeaderField: Headers.CodingKeys.contentType.rawValue)
            }
            if let contentRange = uploadURL.headers.contentRange {
                urlRequest.setValue(contentRange, forHTTPHeaderField: Headers.CodingKeys.contentRange.rawValue)

            }
        case .uploadFileURL(let uploadURL):
            urlRequest.setValue(uploadURL.contentType, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
            urlRequest.setValue("\(uploadURL.contentLength)", forHTTPHeaderField: HTTPHeaderField.contentLength.rawValue)

            if let dropboxAPIPathRoot = uploadURL.headers.dropboxAPIPathRoot {
                urlRequest.setValue(dropboxAPIPathRoot, forHTTPHeaderField: Headers.CodingKeys.dropboxAPIPathRoot.rawValue)
            }

            if let dropboxAPIArg = uploadURL.headers.dropboxAPIArg {
                urlRequest.setValue(dropboxAPIArg, forHTTPHeaderField: Headers.CodingKeys.dropboxAPIArg.rawValue)
            }

            if let authorization = uploadURL.headers.authorization {
                urlRequest.setValue(authorization, forHTTPHeaderField: Headers.CodingKeys.authorization.rawValue)
            }

            if let contentLength = uploadURL.headers.contentLength {
                urlRequest.setValue("\(contentLength)", forHTTPHeaderField: Headers.CodingKeys.contentLength.rawValue)
            }
            if let contentType = uploadURL.headers.contentType {
                urlRequest.setValue(contentType, forHTTPHeaderField: Headers.CodingKeys.contentType.rawValue)
            }
            if let contentRange = uploadURL.headers.contentRange {
                urlRequest.setValue(contentRange, forHTTPHeaderField: Headers.CodingKeys.contentRange.rawValue)

            }
        case .sendFeedback:
            urlRequest.setValue(VCSServer.default.serverURLString, forHTTPHeaderField: HTTPHeaderField.referer.rawValue)
        case .ssoTempUserToken:
            urlRequest.setValue(VCSServer.default.serverURLString, forHTTPHeaderField: HTTPHeaderField.referer.rawValue)
        case .sendVCDOCReply:
            urlRequest.setValue(VCSServer.default.serverURLString, forHTTPHeaderField: HTTPHeaderField.referer.rawValue)
        default:
            break
        }
    }

    func addDefaultHeaders(_ urlRequest: inout URLRequest) {
        switch self {
        case .uploadData:
            DDLogInfo("Skip Default Headers")
        case .uploadFileURL:
            DDLogInfo("Skip Default Headers")
        default:
            APIRouter.addDefaultHeaderTo(request: &urlRequest)
        }
    }

    // MARK: - URLRequestConvertible
    public func asURLRequest() throws -> URLRequest {
        let urlString = self.requestURL.urlString().stringByAppendingPath(path: self.path)
        var url = try urlString.asURL()

        if let queryParametersToAdd = self.queryParameters {
            if var components = URLComponents(string: urlString) {
                components.queryItems = queryParametersToAdd
                url = try components.asURL()
            } else { throw VCSNetworkError.GenericException("Cannot parse url: \(urlString)") }
        }

        var urlRequest = URLRequest(url: url)

        // HTTP Method
        urlRequest.httpMethod = self.method.rawValue

        self.addDefaultHeaders(&urlRequest)
        self.changeHeaders(&urlRequest)

        // Parameters
        if let bodyParameters = self.bodyParameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters, options: [])
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        } else if let bodyData = self.bodyData {
            urlRequest.httpBody = bodyData
        }

        return urlRequest
    }

    public static func addDefaultHeaderTo(request: inout URLRequest) {
        // Common Headers
        request.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        request.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        request.setValue(ClientType.iOS.rawValue, forHTTPHeaderField: HTTPHeaderField.client.rawValue)
        request.setValue(ClientVersion.default.verValue, forHTTPHeaderField: HTTPHeaderField.version.rawValue)
        request.setValue(ClientVersion.default.userAgent, forHTTPHeaderField: HTTPHeaderField.userAgent.rawValue)
    }

    public static func getCSRFToken(key: String) -> String? {
        let CSRFTokenCookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == key })
        return CSRFTokenCookie?.value
    }

    public static func changeLanguageCookie() {
        guard let oldLangCookie = HTTPCookieStorage.shared.cookies?.first(where: { (cookie: HTTPCookie) -> Bool in cookie.name.contains("vwlanguage") }) else { return }
        guard var newCookieProperties = oldLangCookie.properties else { return }

        newCookieProperties[HTTPCookiePropertyKey.value] = Localization.default.preferredLanguage
        if let newLangCookie = HTTPCookie(properties: newCookieProperties) {
            HTTPCookieStorage.shared.deleteCookie(oldLangCookie)
            HTTPCookieStorage.shared.setCookie(newLangCookie)
        }
    }
}
