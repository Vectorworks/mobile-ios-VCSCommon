import Foundation

public enum SharedWithMePermission: Int, Codable {
    case view
    case download
    case modify
    
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .view:
            return "view"
        case .download:
            return "download"
        case .modify:
            return "modify"
        }
    }
    
    public init(rawValue: SharedWithMePermission.RawValue) {
        switch rawValue {
        case "view":
            self = .view
        case "download":
            self = .download
        case "modify":
            self = .modify
        default:
            self = .view
        }
    }
}
