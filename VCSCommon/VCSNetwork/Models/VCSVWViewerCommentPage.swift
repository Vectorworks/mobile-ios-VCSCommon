import Foundation

public struct VCSVWViewerCommentPage: Codable {
    public let dpmm: Double
    public let width: Int
    public let height: Int
    public let sheetName: String
    public let pageNumber: Int
    public let sheetTitle: String

    enum CodingKeys: String, CodingKey {
        case dpmm = "dpmm"
        case width = "width"
        case height = "height"
        case sheetName = "sheetName"
        case pageNumber = "pageNumber"
        case sheetTitle = "sheetTitle"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        dpmm = try values.decode(Double.self, forKey: .dpmm)
        width = try values.decode(Int.self, forKey: .width)
        height = try values.decode(Int.self, forKey: .height)
        sheetName = try values.decode(String.self, forKey: .sheetName)
        pageNumber = try values.decode(Int.self, forKey: .pageNumber)
        sheetTitle = try values.decode(String.self, forKey: .sheetTitle)
    }
    
    public init(dpmm: Double, width: Int, height: Int, sheetName: String, pageNumber: Int, sheetTitle: String) {
        self.dpmm = dpmm
        self.width = width
        self.height = height
        self.sheetName = sheetName
        self.pageNumber = pageNumber
        self.sheetTitle = sheetTitle
    }
}
