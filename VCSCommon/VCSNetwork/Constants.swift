import Foundation

public struct K {
    public struct APIParameterKey {
        public struct oldPublicLink {
            //old public link
            static public let s3file = "s3file"
            static public let publicKey = "public"
            static public let storageType = "storage_type"
        }
        
        public struct jobs {
            //register
            static public let fileVersion = "file_version"
            static public let provider = "provider"
            static public let path = "path"
            static public let owner = "owner"
            static public let jobType = "job_type"
            static public let isFolder = "is_folder"
            static public let options = "options"
            static public let srcStorageType = "src_storage_type"
            static public let srcFileVersions = "src_file_versions"
            static public let outputStorageType = "output_storage_type"
            static public let outputLocation = "output_location"
        }
        
        public struct linkDetailsData {
            static public let url = "url"
        }
        
        public struct mountFolder {
            static public let action = "action"
        }
    }
}

public enum HTTPHeaderField: String {
    case Authorization = "Authorization"
    case contentType = "Content-Type"
    case contentLength = "Content-Length"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
    case client = "X-VCS-Client"
    case version = "X-VCS-Version"
    case userAgent = "User-Agent"
    case referer = "Referer"
    case XCSRFToken = "X-CSRFToken"
    case dropboxAPIPathRoot = "Dropbox-API-Path-Root"
    case dropboxAPIArg = "Dropbox-API-Arg"
}

public enum ContentType: String {
    case json = "application/json"
    case formURLEncoded = "application/x-www-form-urlencoded"
    case textPlain = "text/plain"
}

public enum ClientType: String {
    case iOS = "iOS"
}

public class ClientVersion: NSObject {
    var verValue: String = "0.0"
    public static var privateDefaultInstance: ClientVersion!
    public static var `default`: ClientVersion { return ClientVersion.privateDefaultInstance }
    @objc
    public static var defaultOBJC: ClientVersion { return ClientVersion.default }
    
    public class func setDefault(version: String) {
        ClientVersion.privateDefaultInstance = ClientVersion(version: version)
    }
    
    override init() {
        super.init()
    }
    
    public init(version: String) {
        self.verValue = version
    }
    
    public var userAgent:String {
        return "VCS-iOS/" + self.verValue
    }
}
