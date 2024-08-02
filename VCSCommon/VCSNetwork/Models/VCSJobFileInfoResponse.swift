import Foundation
import SwiftData

@Model
public final class VCSJobFileInfoResponse: Codable {
    public let fileCount: Int
    public let path: String
    public let provider: String
    
    enum CodingKeys: String, CodingKey {
        case fileCount = "file_count"
        case path
        case provider
    }
    
    init(fileCount: Int, path: String, provider: String) {
        self.fileCount = fileCount
        self.path = path
        self.provider = provider
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.fileCount = try container.decode(Int.self, forKey: CodingKeys.fileCount)
        self.path = try container.decode(String.self, forKey: CodingKeys.path)
        self.provider = try container.decode(String.self, forKey: CodingKeys.provider)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.fileCount, forKey: CodingKeys.fileCount)
        try container.encode(self.path, forKey: CodingKeys.path)
        try container.encode(self.provider, forKey: CodingKeys.provider)
    }
}

extension VCSJobFileInfoResponse: VCSCacheable {
    public var rID: String { return path }
}
