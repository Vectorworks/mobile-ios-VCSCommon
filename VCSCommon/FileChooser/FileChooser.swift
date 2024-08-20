import SwiftUI
import CocoaLumberjackSwift

public struct FileChooser: View {
    @State var path: [FCRouteData] = []
    
    @State var fileTypeFilter: FileTypeFilter
    
    @State var rootRoute: FCRouteData
    
    private var itemPickedCompletion: ((VCSFileResponse) -> Void)?
    
    private var onDismiss: (() -> Void)
    
    public init(
        fileTypeFilter: FileTypeFilter,
        itemPickedCompletion: ((VCSFileResponse) -> Void)? = nil,
        onDismiss: @escaping (() -> Void)
    ) {
        guard let s3Storage = VCSUser.savedUser?.availableStorages.first(where: { $0.storageType == .S3 })
        else {
            fatalError("No available storages.")
        }
        self.rootRoute = FCRouteData(resourceURI: s3Storage.folderURI, breadcrumbsName: s3Storage.storageType.displayName)
        self.fileTypeFilter = fileTypeFilter
        self.itemPickedCompletion = itemPickedCompletion
        self.onDismiss = onDismiss
    }
    
    func onStorageChange(selectedStorage: VCSStorageResponse) {
        path.removeAll()
        self.rootRoute = FCRouteData(resourceURI: selectedStorage.folderURI, breadcrumbsName: selectedStorage.storageType.displayName)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            NavigationStack(path: $path) {
                FileExplorerView(
                    fileTypeFilter: fileTypeFilter,
                    path: $path,
                    currentFolderResourceUri: nil,
                    itemPickedCompletion: itemPickedCompletion,
                    onDismiss: onDismiss,
                    onStorageChange: onStorageChange,
                    rootRoute: $rootRoute
                )
                .navigationDestination(for: FCRouteData.self) { routeValue in
                    FileExplorerView(
                        fileTypeFilter: fileTypeFilter,
                        path: $path,
                        currentFolderResourceUri: routeValue.resourceURI,
                        itemPickedCompletion: itemPickedCompletion,
                        onDismiss: onDismiss,
                        onStorageChange: onStorageChange,
                        rootRoute: $rootRoute
                    )
                }
                .tint(.VCSTeal)
            }            
        }
    }
}

