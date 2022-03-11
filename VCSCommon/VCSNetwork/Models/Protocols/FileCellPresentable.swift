import Foundation

@objc public protocol FileCellPresentable: VCSCellPresentable {
    var lastModifiedString: String { get }
    var sizeString: String { get }
    var thumbnailURL: URL? { get }
    var fileTypeString: String? { get }
}
