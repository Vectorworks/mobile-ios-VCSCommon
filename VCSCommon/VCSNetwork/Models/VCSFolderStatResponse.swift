import Foundation

@objc public class VCSFolderStatResponse: NSObject, Codable {
    @objc public let folders, files: VCSAssetStatResponse
}

@objc public class VCSAssetStatResponse: NSObject, Codable {
    @objc public let count: Int
}
