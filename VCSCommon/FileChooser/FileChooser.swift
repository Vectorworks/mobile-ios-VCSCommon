import SwiftUI
import CocoaLumberjackSwift

public struct FileChooser: View {
    @StateObject var viewModel: FileChooserViewModel
    
    private var itemPickedCompletion: ((VCSFileResponse) -> Void)?
    
    private var onDismiss: (() -> Void)
    
    public init(
        fileTypeFilter: FileTypeFilter,
        itemPickedCompletion: ((VCSFileResponse) -> Void)? = nil,
        onDismiss: @escaping (() -> Void)
    ) {
        let s3ResourceUri = VCSUser.savedUser?.availableStorages.first(where: { $0.storageType == .S3 })?.folderURI ?? ""
        let initialPath = [FCRouteData(resourceURI: s3ResourceUri, breadcrumbsName: "Home")]
        _viewModel = StateObject(wrappedValue:FileChooserViewModel(fileTypeFilter: fileTypeFilter, initialPath: initialPath))
        self.itemPickedCompletion = itemPickedCompletion
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            FileExplorerView(
                fileTypeFilter: viewModel.fileTypeFilter,
                path: $viewModel.path,
                currentFolderResourceUri: viewModel.initialFolderResourceUri,
                itemPickedCompletion: itemPickedCompletion,
                onDismiss: onDismiss
            )
            .navigationDestination(for: FCRouteData.self) { routeValue in
                FileExplorerView(
                    fileTypeFilter: viewModel.fileTypeFilter,
                    path: $viewModel.path,
                    currentFolderResourceUri: routeValue.resourceURI,
                    itemPickedCompletion: itemPickedCompletion,
                    onDismiss: onDismiss
                )
            }
        }
        .tint(.VCSTeal)
    }
}

class FileChooserViewModel: ObservableObject {
    @Published var path: [FCRouteData]
    
    @Published var fileTypeFilter: FileTypeFilter
    
    var initialFolderResourceUri: String {
        VCSUser.savedUser?.availableStorages.first(where: { $0.storageType == .S3 })?.folderURI ?? ""
    }
    
    init(fileTypeFilter: FileTypeFilter, initialPath: [FCRouteData] = []) {
        self.fileTypeFilter = fileTypeFilter
        self.path = initialPath
    }
}

