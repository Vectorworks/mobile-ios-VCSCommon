import Foundation

public class WebViewTaskAssetResult: Codable
{
    public let storageType: String
    public let owner: String
    public let path: String
    public let fileType: String
    public let isFolder: Bool
    
    private enum CodingKeys: String, CodingKey {
        case storageType = "storage_type"
        case owner
        case path
        case fileType = "file_type"
        case isFolder = "is_folder"
    }
}
