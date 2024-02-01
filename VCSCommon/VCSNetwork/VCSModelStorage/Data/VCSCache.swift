import Foundation

public protocol VCSCachable {
    func addToCache()
    func addOrPartialUpdateToCache()
    func partialUpdateToCache()
}

public class VCSCache {
    /**
     - Parameters:
        - item: The item to be updated
        - forceNilValuesUpdate: Defaults to *false*. Should be set to *true* when trying to achieve field deletion. Otherwise the *nil* fields will **not** be updated.
     */
    public static func addToCache(item: VCSCachable, forceNilValuesUpdate: Bool = false, skipRootFolderID: Bool = false) {
        //Hack partial update of Folders. Only update files and subfolders for root response level due to api limitation
        VCSFolderResponse.addToCacheRootFolderID = nil
        if skipRootFolderID == false {
            if item is VCSFolderResponse {
                VCSFolderResponse.addToCacheRootFolderID = (item as? VCSFolderResponse)?.rID
            }
            if item is VCSShareableLinkResponse {
                VCSFolderResponse.addToCacheRootFolderID = (item as? VCSShareableLinkResponse)?.asset.rID
            }
            if item is VCSSharedWithMeAsset {
                VCSFolderResponse.addToCacheRootFolderID = (item as? VCSSharedWithMeAsset)?.asset.rID
            }
            if item is SharedLink {
                VCSFolderResponse.addToCacheRootFolderID = (item as? SharedLink)?.sharedAsset?.asset.rID
            }
        }
        
        if (forceNilValuesUpdate) {
            item.addToCache()
        } else {
            item.addOrPartialUpdateToCache()
        }
    }
}
