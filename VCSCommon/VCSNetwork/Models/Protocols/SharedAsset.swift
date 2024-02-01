import Foundation

public protocol SharedAsset {
    var asset: Asset { get }
    var assetType: AssetType { get }
    var resourceURI: String { get }
}
