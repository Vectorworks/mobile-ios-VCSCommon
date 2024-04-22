import Foundation

public class WebViewPresentationsOpenLocalAssetResultFlags: Codable {
    public let isSupported: Bool
    public let isNameValid: Bool
    public let isFileTypeSupported: Bool
    public let isNameDuplicate: Bool

    enum CodingKeys: String, CodingKey {
        case isSupported = "is_supported"
        case isNameValid = "is_name_valid"
        case isFileTypeSupported = "is_file_type_supported"
        case isNameDuplicate = "is_name_duplicate"
    }
}
