import SwiftUI

public struct PagesLoadingButtons: View {
    @Binding var path: [FCRouteData]
    @Binding var rootRouteData: FCRouteData
    @Binding var resultFolder: Result<VCSFolderResponse, Error>?
    @Binding var selectedStorage: VCSStorageResponse?
    @Binding var showPagesChooser: Bool
    
    public var body: some View {
        ForEach(selectedStorage?.pages ?? [], id: \.id) { storagePage in
            Button {
                path.removeAll()
                showPagesChooser = false
                rootRouteData = FCRouteData(resourceURI: storagePage.folderURI, breadcrumbsName: storagePage.displayName)
                resultFolder = nil
            } label: {
                Label(selectedStorage?.storageType.displayName ?? "", image: selectedStorage?.storageType.storageImageName ?? "")
            }
        }
        Button(FolderChooserSettings.cancelButtonTitle.vcsLocalized, role: .cancel) {}
    }
}
