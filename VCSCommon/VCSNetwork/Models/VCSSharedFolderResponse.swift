import Foundation

@objc public class SharedFolderResponse: NSObject, Codable {
    public let count: Int
    public let next, previous: String?
    public let results: [VCSSharedAssetWrapper?]
}
