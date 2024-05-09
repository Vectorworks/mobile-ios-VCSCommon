import Foundation

public enum StorageType: String, Codable, Equatable {
    case INTERNAL = "internal"
    case S3 = "s3"
    case DROPBOX = "dropbox"
    case GOOGLE_DRIVE = "google_drive"
    case ONE_DRIVE = "one_drive"
    
    public var displayName: String {
        switch self {
        case .INTERNAL:
            return "Internal".vcsLocalized
        case .S3:
            return "Home".vcsLocalized
        case .DROPBOX:
            return "Dropbox"
        case .GOOGLE_DRIVE:
            return "Google Drive"
        case .ONE_DRIVE:
            return "OneDrive"
        }
    }
    
    public var isExternal: Bool {
        switch self {
        case .INTERNAL:
            return false
        case .S3:
            return false
        case .DROPBOX:
            return true
        case .GOOGLE_DRIVE:
            return true
        case .ONE_DRIVE:
            return true
        }
    }
    
    public var storageImageName: String {
        switch self {
        case .INTERNAL:
            return ""
        case .S3:
            return "home"
        case .DROPBOX:
            return "dropbox"
        case .GOOGLE_DRIVE:
            return "gdrive"
        case .ONE_DRIVE:
            return "onedrive"
        }
    }
    
    public static func typeFromString(type: String) -> StorageType {
        switch type {
        case StorageType.INTERNAL.rawValue:
            return StorageType.INTERNAL
        case StorageType.S3.rawValue:
            return StorageType.S3
        case StorageType.DROPBOX.rawValue:
            return StorageType.DROPBOX
        case StorageType.GOOGLE_DRIVE.rawValue:
            return StorageType.GOOGLE_DRIVE
        case StorageType.ONE_DRIVE.rawValue:
            return StorageType.ONE_DRIVE
        default:
            return StorageType.S3
        }
    }
    
    public var loginSettingsIntegrateUrlKey: String {
        switch self {
        case .DROPBOX:
            return AuthCenter.shared.loginSettings?.dropboxIntegrateURL ?? "none"
        case .GOOGLE_DRIVE:
            return AuthCenter.shared.loginSettings?.driveIntegrateURL ?? "none"
        case .ONE_DRIVE:
            return AuthCenter.shared.loginSettings?.oneDriveIntegrateURL ?? "none"
        default:
            return "none"
        }
    }
    
    public var itemIdentifier: String {
        switch self {
        case .INTERNAL:
            return "INTERNAL-Identifier"
        case .S3:
            return "S3-Identifier"
        case .DROPBOX:
            return "DROPBOX-Identifier"
        case .GOOGLE_DRIVE:
            return "GOOGLE_DRIVE-Identifier"
        case .ONE_DRIVE:
            return "ONE_DRIVE-Identifier"
        }
    }
}
