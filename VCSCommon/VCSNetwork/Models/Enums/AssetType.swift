import Foundation

@objc public enum AssetType: Int, Codable {
    case file
    case folder
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .file:
            return "file"
        case .folder:
            return "folder"
        }
    }
    
    public init(rawValue: AssetType.RawValue) {
        switch rawValue {
        case "file":
            self = .file
        case "folder":
            self = .folder
        default:
            self = .file
        }
    }
}
