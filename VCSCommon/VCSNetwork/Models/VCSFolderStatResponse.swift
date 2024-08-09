import Foundation

public class VCSFolderStatResponse: Codable {
    public let folders, files: VCSAssetStatResponse
}

public class VCSAssetStatResponse: Codable {
    public let count: Int
}
