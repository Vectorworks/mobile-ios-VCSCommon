import Foundation

public class VCSPresentationsResponse: Codable {
    public let count: Int?
    public let next: String?
    public let previous: String?
    public let results: [VCSPresentationResponseResult]

    enum CodingKeys: String, CodingKey {
        case count = "count"
        case next = "next"
        case previous = "previous"
        case results = "results"
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        count = try values.decodeIfPresent(Int.self, forKey: .count)
        next = try values.decodeIfPresent(String.self, forKey: .next)
        previous = try values.decodeIfPresent(String.self, forKey: .previous)
        results = try values.decode([VCSPresentationResponseResult].self, forKey: .results)
    }
}
