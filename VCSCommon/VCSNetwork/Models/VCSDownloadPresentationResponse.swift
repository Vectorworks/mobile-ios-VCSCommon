import Foundation

public class VCSDownloadPresentationResponse : Codable {
    public let status : String

    enum CodingKeys: String, CodingKey {
        case status = "status"
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decode(String.self, forKey: .status)
    }
}
