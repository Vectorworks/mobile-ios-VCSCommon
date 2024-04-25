import Foundation

public class WebViewTaskDialogResult: Codable
{
    public let asset: WebViewTaskAssetResult
    public let sharingInfo: VCSSharingInfoResponse
    
    private enum CodingKeys: String, CodingKey {
        case asset
        case sharingInfo = "sharing_info"
    }
    
    public func updateDB(_ assets: [VCSCellDataHolder]) {
        guard let item = assets.first(where: { (cellDataHolder) -> Bool in
            var webAssetPath = self.asset.path
            if (cellDataHolder.assetData?.prefix.hasSuffix("/") ?? false) && !self.asset.path.hasSuffix("/") {
                webAssetPath += "/"
            }
            return self.asset.owner == cellDataHolder.assetData?.ownerLogin
            && self.asset.storageType == cellDataHolder.assetData?.storageTypeString
            && webAssetPath  == cellDataHolder.assetData?.prefix
            
        }) else { return }
        
        (item as? VCSFileResponse)?.loadLocalFiles()
        item.updateSharingInfo(other: self.sharingInfo)
    }
}
