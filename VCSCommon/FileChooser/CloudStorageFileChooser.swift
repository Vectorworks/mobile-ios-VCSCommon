import SwiftUI
import CocoaLumberjackSwift
import UIKit
import RealmSwift

struct CloudStorageFileChooser: View {
    @ObservedObject private var viewsLayoutSetting: ViewsLayoutSetting = ViewsLayoutSetting.listDefault
    
    @ObservedObject private var VCSReachabilityMonitor = VCSReachability.default
    
    @ObservedResults(VCSUser.RealmModel.self, where: { $0.isLoggedIn == true }) var users
    
    @StateObject private var viewModel: CloudStorageViewModel
    
    @Binding var rootRoute: FileChooserRouteData
    
    @State var currentRoute: FileChooserRouteData
    
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
        _viewModel = StateObject(wrappedValue: CloudStorageViewModel(fileTypeFilter: fileTypeFilter))
        self.itemPickedCompletion = itemPickedCompletion
        self.onDismiss = onDismiss
        self._rootRoute = rootRoute
        self.currentRoute = currentRoute
        self.isInRoot = currentRoute == rootRoute.wrappedValue
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                CurrentFilterView(
                    onDismiss: onDismiss,
                    fileTypeFilter: viewModel.fileTypeFilter
                )
                
                switch viewModel.viewState {
                case .loaded:
                    Group {
                        switch viewsLayoutSetting.layout.asListLayoutCriteria {
                        case .list :
                            ListView(
                                models: viewModel.models,
                                currentRouteData: $currentRoute,
                                itemPickedCompletion: itemPickedCompletion,
                                onDismiss: onDismiss,
                                isInRoot: isInRoot,
                                isGuest: isGuest
                            )
                        case .grid :
                            GridView(
                                models: viewModel.models,
                                currentRouteData: $currentRoute,
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
                            viewModel.loadFolder(route: currentRoute, isConnectionAvailable: VCSReachabilityMonitor.isConnected)
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .onChange(of: rootRoute) { oldValue, newValue in
                if isInRoot {
                    currentRoute = newValue
                    viewModel.loadFolder(route: currentRoute, isConnectionAvailable: VCSReachabilityMonitor.isConnected)
                }
            }
        }
    }
}
