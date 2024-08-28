import SwiftUI
import CocoaLumberjackSwift
import UIKit
import RealmSwift

struct FileExplorerView: View {
    @ObservedObject private var viewsLayoutSetting: ViewsLayoutSetting = ViewsLayoutSetting.listDefault
    
    @ObservedResults(VCSUser.RealmModel.self, where: { $0.isLoggedIn == true }) var users
    
    @StateObject private var viewModel: FileExplorerViewModel
    
    @Binding var path: [FCRouteData]
    
    @Binding var rootRoute: FCRouteData
    
    @State var currentFolderResourceUri: String?
    
    var itemPickedCompletion: ((VCSFileResponse) -> Void)?
    
    var onDismiss: (() -> Void)
    
    private var isInRoot: Bool {
        path.count == 0
    }
    
    private var isGuest: Bool {
        users.first?.entity == nil
    }
    
    init(fileTypeFilter: FileTypeFilter,
         path: Binding<[FCRouteData]>,
         currentFolderResourceUri: String?,
         itemPickedCompletion: ((VCSFileResponse) -> Void)?,
         onDismiss: @escaping (() -> Void),
         rootRoute: Binding<FCRouteData>) {
        _viewModel = StateObject(wrappedValue: FileExplorerViewModel(fileTypeFilter: fileTypeFilter))
        self._path = path
        self.currentFolderResourceUri = currentFolderResourceUri
        self.itemPickedCompletion = itemPickedCompletion
        self.onDismiss = onDismiss
        self._rootRoute = rootRoute
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Button(
                    action: {
                        onDismiss()
                    },
                    label : {
                        FileChooserActiveFilterView(fileTypeFilter: viewModel.fileTypeFilter)
                    }
                )
                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? geometry.size.width * 0.2 : geometry.size.width * 0.4)

                switch viewModel.resultFolder {
                case .success(_):
                    Group {
                        switch viewsLayoutSetting.layout.asListLayoutCriteria {
                        case .list :
                            FileExplorerListView(
                                folders: $viewModel.sortedFolders,
                                files: $viewModel.sortedFiles,
                                itemPickedCompletion: itemPickedCompletion,
                                getThumbnailURL: viewModel.getThumbnailURL,
                                onDismiss: onDismiss,
                                isInRoot: isInRoot,
                                isGuest: isGuest
                            )
                        case .grid :
                            FileExplorerGridView(
                                folders: $viewModel.sortedFolders,
                                files: $viewModel.sortedFiles,
                                itemPickedCompletion: itemPickedCompletion,
                                getThumbnailURL: viewModel.getThumbnailURL,
                                onDismiss: onDismiss,
                                isInRoot: isInRoot,
                                isGuest: isGuest
                            )
                        }
                    }
                    
                case .failure(let error):
                    ErrorView(error: error, onDismiss: onDismiss)
                    
                case nil:
                    ProgressView()
                        .onAppear {
                            viewModel.loadFolder(resourceUri: currentFolderResourceUri ?? rootRoute.resourceURI)
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .onChange(of: rootRoute) { oldValue, newValue in
                if isInRoot {
                    viewModel.loadFolder(resourceUri: newValue.resourceURI)
                }
            }
        }
    }
}
