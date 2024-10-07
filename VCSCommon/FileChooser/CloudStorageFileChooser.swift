import SwiftUI
import CocoaLumberjackSwift
import UIKit
import RealmSwift

struct CloudStorageFileChooser: View {
    @ObservedObject private var viewsLayoutSetting: ViewsLayoutSetting = ViewsLayoutSetting.listDefault
    
    @ObservedObject private var VCSReachabilityMonitor = VCSReachability.default
    
    @ObservedResults(VCSUser.RealmModel.self, where: { $0.isLoggedIn == true }) var users
    
    @ObservedResults(VCSFolderResponse.RealmModel.self) var currentFolderRawData
    
    @StateObject private var viewModel: CloudStorageViewModel
    
    @Binding var rootRoute: FileChooserRouteData
    
    var itemPickedCompletion: ((FileChooserModel) -> Void)?
    
    var onDismiss: () -> Void
    
    private var isInRoot: Bool
    
    private var isGuest: Bool {
        users.first?.entity == nil
    }
    
    init(fileTypeFilter: FileTypeFilter,
         itemPickedCompletion: ((FileChooserModel) -> Void)?,
         onDismiss: @escaping (() -> Void),
         rootRoute: Binding<FileChooserRouteData>,
         currentRoute: FileChooserRouteData) {
        _viewModel = StateObject(wrappedValue: CloudStorageViewModel(fileTypeFilter: fileTypeFilter, currentRoute: currentRoute))
        self.itemPickedCompletion = itemPickedCompletion
        self.onDismiss = onDismiss
        self._rootRoute = rootRoute
        self.isInRoot = currentRoute == rootRoute.wrappedValue
    }
    
    var body: some View {
        GeometryReader { _ in
            VStack(alignment: .center) {
                CurrentFilterView(
                    onDismiss: onDismiss,
                    fileTypeFilter: viewModel.fileTypeFilter
                )
                
                switch viewModel.viewState {
                case .loaded, .offline:
                    let models = viewModel.mapToModels(
                        currentFolderResults: currentFolderRawData
                    )
                    
                    Group {
                        switch viewsLayoutSetting.layout.asListLayoutCriteria {
                        case .list:
                            ListView(
                                models: models,
                                currentRouteData: $viewModel.currentRoute,
                                itemPickedCompletion: itemPickedCompletion,
                                onDismiss: onDismiss,
                                isInRoot: isInRoot,
                                isGuest: isGuest
                            )
                        case .grid:
                            GridView(
                                models: models,
                                currentRouteData: $viewModel.currentRoute,
                                itemPickedCompletion: itemPickedCompletion,
                                onDismiss: onDismiss,
                                isInRoot: isInRoot,
                                isGuest: isGuest
                            )
                        }
                    }
                    
                case .error(let error):
                    ErrorView(error: error, onDismiss: onDismiss)
                    
                case .loading:
                    ProgressView()
                        .onAppear {
                            viewModel.loadFolder()
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .onChange(of: rootRoute) { _, newValue in
                if isInRoot {
                    viewModel.currentRoute = newValue
                    viewModel.loadFolder()
                }
            }
            .onChange(of: VCSReachabilityMonitor.isConnected) { _, isConnected in
                if isConnected {
                    viewModel.loadFolder()
                } else {
                    viewModel.viewState = .offline
                }
                
            }
        }
    }
}
