import Foundation

public class WebViewTaskDialogResult: Codable
{
    public let asset: WebViewTaskAssetResult
    public let sharingInfo: VCSSharingInfoResponse
    
    private enum CodingKeys: String, CodingKey {
        case asset
        case sharingInfo = "sharing_info"
    }
    
    public func updateDB(_ assets: [Asset]) {
        guard let item = assets.first(where: { (asset) -> Bool in
            var webAssetPath = self.asset.path
            if asset.prefix.hasSuffix("/") && !self.asset.path.hasSuffix("/") {
                webAssetPath += "/"
            }
            return self.asset.owner == asset.ownerLogin
                && self.asset.storageType == asset.storageTypeString
                && webAssetPath  == asset.prefix
            
        }) else { return }
        
        (item as? VCSFileResponse)?.loadLocalFiles()
        item.updateSharingInfo(other: self.sharingInfo)
    }
}
