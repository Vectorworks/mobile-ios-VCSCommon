import Foundation

public class VCSSharedWithMeResponse: Codable {
    public let count: Int
    public let next, previous: String?
    public let results: [VCSSharedWithMeAsset?]
}
