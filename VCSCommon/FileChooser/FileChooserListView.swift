import SwiftUI
import CocoaLumberjackSwift
import UIKit
import RealmSwift

enum PaginationState {
    case hasNextPage
    case loadingNextPage
    case noMorePages
}

struct FileChooserListView<ViewModel: FileLoadable>: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject private var viewsLayoutSetting: ViewsLayoutSetting = ViewsLayoutSetting.listDefault
    
    @ObservedObject private var VCSReachabilityMonitor = VCSReachability.default
    
    @ObservedObject private var viewModel: ViewModel
    
    @ObservedResults(VCSUser.RealmModel.self, where: { $0.isLoggedIn == true }) var users
            
    var models: [FileChooserModel]
    
    var itemPickedCompletion: (FileChooserModel) -> Void
    
    var onDismiss: () -> Void
    
    init(
        viewModel: ViewModel,
        models: [FileChooserModel],
        itemPickedCompletion: @escaping (FileChooserModel) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.models = models
        self.itemPickedCompletion = itemPickedCompletion
        self.onDismiss = onDismiss
    }
    
    private var isGuest: Bool {
        users.first?.entity == nil
    }
    
    private var adaptiveBackgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white
    }
    
    private var hasMorePages: Bool {
        viewModel.hasMorePages.values.contains(true)
    }
    
    private var shouldShowSharedWithMe: Bool {
        switch viewModel.route {
        case .s3:
            return true
        default:
            return false
        }
    }
    
    private var shouldShowPaginationProgressSpinner: Bool {
        hasMorePages && VCSReachabilityMonitor.isConnected
    }
    
    private func loadFilesForCurrentState() async {
        if viewModel.paginationState == .loadingNextPage {
            return
        }
        
        if VCSReachabilityMonitor.isConnected && !isGuest {
            await viewModel.loadNextPage(silentRefresh: false)
        } else if isGuest {
            await viewModel.loadFilesForGuestMode()
        } else {
            viewModel.changeViewState(to: .loaded)
        }
    }
    
    func onListEndReached() async {
        if !hasMorePages {
            viewModel.changePaginationState(to: .noMorePages)
        } else if VCSReachabilityMonitor.isConnected && !isGuest {
            await viewModel.loadNextPage(silentRefresh: true)
        } else if isGuest {
            viewModel.changePaginationState(to: .noMorePages)
        }
    }
    
    var body: some View {
        GeometryReader { _ in
            VStack(alignment: .center) {
                CurrentFilterView(
                    onDismiss: onDismiss,
                    fileTypeFilter: viewModel.fileTypeFilter
                )
                
                switch viewModel.viewState {
                case .error(let error):
                    ErrorView(error: error, onDismiss: onDismiss)
                    
                case .loading:
                    ProgressView()
                        .onAppear {
                            Task {
                                await loadFilesForCurrentState()
                            }
                        }
                    
                default:
                    if models.isEmpty && viewModel.sharedWithMe {
                        if !VCSReachabilityMonitor.isConnected {
                            OfflineEmptyView()
                        } else {
                            FilteredEmptyView()
                        }
                    } else {
                        contentView
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .onChange(of: viewModel.route) { _, route in
                if VCSReachabilityMonitor.isConnected {
                    Task {
                        await viewModel.loadNextPage(silentRefresh: false)
                    }
                }
            }
            .onChange(of: VCSReachabilityMonitor.isConnected) { _, _ in
                Task {
                    await loadFilesForCurrentState()
                }
            }
        }
    }
    
    var contentView: some View {
        Group {
            switch viewsLayoutSetting.layout.asListLayoutCriteria {
            case .list:
                listView
            case .grid:
                gridView
            }
        }
        .onAppear {
            viewModel.updatePaginationWithLoadedFiles(models: models)
        }
    }
    
    var gridView: some View {
        ScrollView {
            if shouldShowSharedWithMe && !isGuest {
                NavigationLink(value: FileChooserRouteData.sharedWithMeRoot) {
                    VStack {
                        HStack {
                            sharedWithMeItem
                                .padding()
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(adaptiveBackgroundColor)
                        .cornerRadius(10)
                        .padding(10)
                        
                        Divider()
                            .background(Color.white)
                            .frame(height: 1)
                            .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
                    }
                }
            }
            
            LazyVGrid(columns: [.init(.adaptive(minimum: K.Sizes.gridMinCellSize))], spacing: 20) {
                ForEach(models, id: \.resourceUri) { file in
                    Button {
                        onDismiss()
                        itemPickedCompletion(file)
                    } label: {
                        GridItemView(
                            thumbnailURL: file.thumbnailUrl,
                            flags: file.flags,
                            name: file.name,
                            isFolder: false,
                            lastDateModified: file.lastDateModified
                        )
                        .padding(8)
                        .background(adaptiveBackgroundColor)
                        .cornerRadius(10)
                    }
                }
                
                if shouldShowPaginationProgressSpinner {
                    paginationProgressView
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    var listView: some View {
        ScrollViewReader { scrollProxy in
            List {
                if shouldShowSharedWithMe && !isGuest {
                    Section {
                        NavigationLink(value: FileChooserRouteData.sharedWithMeRoot) {
                            sharedWithMeItem
                        }
                    }
                }
                
                Section {
                    ForEach(models) { file in
                        Button {
                            onDismiss()
                            itemPickedCompletion(file)
                        } label: {
                            ListItemView(
                                thumbnailURL: file.thumbnailUrl,
                                flags: file.flags,
                                name: file.name,
                                isFolder: false,
                                lastDateModified: file.lastDateModified
                            )
                        }
                        .id(file.id)
                    }
                }
                
                if shouldShowPaginationProgressSpinner {
                    paginationProgressView
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }
    
    var sharedWithMeItem: some View {
        ListItemView(
            thumbnailURL: nil,
            flags: nil,
            name: "Shared with me".vcsLocalized,
            isFolder: true,
            isSharedWithMeFolder: true
        )
    }
    
    var listItemProgressView: some View {
        HStack {
            Spacer()
            ProgressView()
                .background(Color.clear)
            Spacer()
        }
        .background(Color.clear)
    }
    
    var paginationProgressView: some View {
        let progressView: AnyView
        
        switch viewsLayoutSetting.layout.asListLayoutCriteria {
        case .list:
            progressView = AnyView(listItemProgressView)
        case .grid:
            progressView = AnyView(ProgressView())
        }
        
        return Group {
            switch viewModel.paginationState {
            case .hasNextPage:
                progressView
                    .onAppear {
                        Task {
                            await onListEndReached()
                        }
                    }
            case .loadingNextPage:
                progressView
            case .noMorePages:
                EmptyView()
            }
        }
    }
}
