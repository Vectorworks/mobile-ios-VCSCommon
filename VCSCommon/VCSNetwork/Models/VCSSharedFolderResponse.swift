import Foundation

public class SharedFolderResponse: Codable {
    public let count: Int
    public let next, previous: String?
    public let results: [VCSSharedAssetWrapper?]
}
