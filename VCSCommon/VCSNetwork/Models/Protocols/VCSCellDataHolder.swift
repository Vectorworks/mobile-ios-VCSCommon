import Foundation

public protocol VCSCellDataHolder {
    var cellData: VCSCellPresentable { get }
    var cellFileData: FileCellPresentable? { get }
    var assetData: Asset? { get }
}

public extension Array where Element == VCSCellDataHolder {
    var assetArray: [Asset] { return self.compactMap { return $0.assetData } }
}
