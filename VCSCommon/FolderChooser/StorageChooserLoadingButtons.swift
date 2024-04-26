import SwiftUI
import CocoaLumberjackSwift

struct StorageChooserLoadingButtons: View {
    @Binding var path: [FCRouteData]
    @Binding var rootRouteData: FCRouteData
    @Binding var resultFolder: Result<VCSFolderResponse, Error>?
    @Binding var showStorageChooser: Bool
    @Binding var showPagesChooser: Bool
    @Binding var selectedStorage: VCSStorageResponse?
    
    var body: some View {
        ForEach(VCSUser.savedUser?.availableStorages ?? [], id: \.storageType) { (currentStorage: VCSStorageResponse) in
            Button {
//                if currentStorage.storageType == .GOOGLE_DRIVE || currentStorage.storageType == .ONE_DRIVE {
//                    guard let pagesURL = currentStorage.pagesURL else { return }
//                    
//                    APIClient.getStoragePagesList(storagePagesURI: pagesURL).execute { (result: StoragePagesList) in
//                        currentStorage.setStoragePagesList(storagePages: result)
//                        VCSCache.addToCache(item: currentStorage)
//                        showStorageChooser = false
//                        showPagesChooser = true
//                        selectedStorage = currentStorage
//                    } onFailure: { (error: Error) in
//                        if error.responseCode == VCSNetworkErrorCode.noInternet.rawValue {
//                            if currentStorage.pages.count == 0 {
//                                path.removeAll()
//                                showStorageChooser = false
//                                rootRouteData = FCRouteData(resourceURI: currentStorage.folderURI, breadcrumbsName: currentStorage.storageType.displayName)
//                                resultFolder = nil
//                            } else {
//                                showStorageChooser = false
//                                showPagesChooser = true
//                                selectedStorage = currentStorage
//                            }
//                        } else {
//                            DDLogError("change storage page error = \(error.localizedDescription)")
//                        }
//                    }
//                } else {
                    path.removeAll()
                    showStorageChooser = false
                    rootRouteData = FCRouteData(resourceURI: currentStorage.folderURI, breadcrumbsName: currentStorage.storageType.displayName)
                    resultFolder = nil
//                }
            } label: {
                Label(currentStorage.storageType.displayName, image: currentStorage.storageType.storageImageName)
            }
        }
        Button(FolderChooserSettings.cancelButtonTitle.vcsLocalized, role: .cancel) {}
    }
}
