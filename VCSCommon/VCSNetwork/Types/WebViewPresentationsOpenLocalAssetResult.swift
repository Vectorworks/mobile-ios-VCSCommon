import Foundation

public class WebViewPresentationsOpenLocalAssetResult: Codable {
    public let storageType: String
    public let name: String
    public let isNameValid: Bool
    public let prefix: String
    public let fileType: String
    public let versionID: String
    public let exists: Bool
    public let lastModified: String
    public let size: String
    public let isSupported: Bool
    public let flags: WebViewPresentationsOpenLocalAssetResultFlags
    public let thumbnail: String
    public let resourceURI: String
    public let downloadURL: String

    enum CodingKeys: String, CodingKey {
        case storageType = "storage_type"
        case name = "name"
        case isNameValid = "is_name_valid"
        case prefix = "prefix"
        case fileType = "file_type"
        case versionID = "version_id"
        case exists = "exists"
        case lastModified = "last_modified"
        case size = "size"
        case isSupported = "is_supported"
        case flags = "flags"
        case thumbnail = "thumbnail"
        case resourceURI = "resource_uri"
        case downloadURL = "download_url"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.storageType = try values.decode(String.self, forKey: .storageType)
        self.name = try values.decode(String.self, forKey: .name)
        self.isNameValid = try values.decode(Bool.self, forKey: .isNameValid)
        self.prefix = try values.decode(String.self, forKey: .prefix)
        self.fileType = try values.decode(String.self, forKey: .fileType)
        self.versionID = try values.decode(String.self, forKey: .versionID)
        self.exists = try values.decode(Bool.self, forKey: .exists)
        self.lastModified = try values.decode(String.self, forKey: .lastModified)
        self.size = try values.decode(String.self, forKey: .size)
        self.isSupported = try values.decode(Bool.self, forKey: .isSupported)
        self.flags = try values.decode(WebViewPresentationsOpenLocalAssetResultFlags.self, forKey: .flags)
        self.thumbnail = try values.decode(String.self, forKey: .thumbnail)
        self.resourceURI = try values.decode(String.self, forKey: .resourceURI)
        self.downloadURL = try values.decode(String.self, forKey: .downloadURL)
    }
}
