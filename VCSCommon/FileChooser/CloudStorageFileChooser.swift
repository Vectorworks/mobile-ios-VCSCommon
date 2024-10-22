import SwiftUI
import CocoaLumberjackSwift
import UIKit
import RealmSwift

struct CloudStorageFileChooser: View {
    @ObservedObject private var viewsLayoutSetting: ViewsLayoutSetting = ViewsLayoutSetting.listDefault
    
    @ObservedObject private var VCSReachabilityMonitor = VCSReachability.default
    
    @ObservedResults(VCSUser.RealmModel.self, where: { $0.isLoggedIn == true }) var users
    
    @ObservedResults(VCSFileResponse.RealmModel.self, where: { $0.ownerLogin == VCSUser.savedUser?.login ?? "nil" }) var allFiles
    
    @StateObject private var viewModel: CloudStorageViewModel
    
    @Binding var route: FileChooserRouteData
          
    var itemPickedCompletion: ((FileChooserModel) -> Void)?
    
    var onDismiss: () -> Void
    
    private var isGuest: Bool {
        users.first?.entity == nil
    }
    
    private var shouldShowSharedWithMe: Bool {
        switch route {
        case .s3(_) :
            return true
        default:
            return false
        }
    }
    
    init(fileTypeFilter: FileTypeFilter,
         itemPickedCompletion: ((FileChooserModel) -> Void)?,
         onDismiss: @escaping (() -> Void),
         route: Binding<FileChooserRouteData>) {
        _viewModel = StateObject(wrappedValue: CloudStorageViewModel(fileTypeFilter: fileTypeFilter))
        self.itemPickedCompletion = itemPickedCompletion
        self.onDismiss = onDismiss
        self._route = route
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
                    let models = viewModel.filterAndMapToModels(
                        allFiles: allFiles,
                        storageType: route.storageType.rawValue
                    )
                    
                    Group {
                        switch viewsLayoutSetting.layout.asListLayoutCriteria {
                        case .list:
                            ListView(
                                shouldShowSharedWithMe: shouldShowSharedWithMe,
                                models: models,
                                itemPickedCompletion: itemPickedCompletion,
                                onDismiss: onDismiss,
                                isGuest: isGuest
                            )
                        case .grid:
                            GridView(
                                shouldShowSharedWithMe: shouldShowSharedWithMe,
                                models: models,
                                itemPickedCompletion: itemPickedCompletion,
                                onDismiss: onDismiss,
                                isGuest: isGuest
                            )
                        }
                    }
                    
                case .error(let error):
                    ErrorView(error: error, onDismiss: onDismiss)
                    
                case .loading:
                    ProgressView()
                        .onAppear {
                            if VCSReachabilityMonitor.isConnected {
                                Task {
                                    await viewModel.loadFilesWithCurrentFilter(storageType: route.storageType.rawValue)
                                }
                            } else {
                                viewModel.viewState = .offline
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .onChange(of: route) { _, _ in
                if viewModel.viewState != .offline {
                    Task {
                        await viewModel.loadFilesWithCurrentFilter(storageType: route.storageType.rawValue)
                    }
                }
            }
            .onChange(of: VCSReachabilityMonitor.isConnected) { _, isConnected in
                if isConnected {
                    Task {
                        await viewModel.loadFilesWithCurrentFilter(storageType: route.storageType.rawValue)
                    }
                } else {
                    viewModel.viewState = .offline
                }
                
            }
        }
    }
}
