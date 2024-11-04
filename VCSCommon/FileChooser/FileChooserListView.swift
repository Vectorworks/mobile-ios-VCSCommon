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
    
    @Binding var viewState: FileChooserViewState
    
    var fileTypeFilter: FileTypeFilter
    
    var models: [FileChooserModel]
    
    var itemPickedCompletion: (FileChooserModel) -> Void
    
    var onDismiss: () -> Void
    
    init(
        viewModel: ViewModel,
        viewState: Binding<FileChooserViewState>,
        fileTypeFilter: FileTypeFilter,
        models: [FileChooserModel],
        itemPickedCompletion: @escaping (FileChooserModel) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self._viewState = viewState
        self.fileTypeFilter = fileTypeFilter
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
    
    private func loadFilesForCurrentState() {
        if viewModel.paginationState == .loadingNextPage {
            return
        }
        
        if VCSReachabilityMonitor.isConnected && !isGuest {
            Task {
                await viewModel.loadNextPage(silentRefresh: false)
            }
        } else if isGuest {
            viewModel.loadSampleFiles()
        } else {
            viewModel.viewState = .loaded
        }
    }
    
    func onListEndReached() {
        if !hasMorePages {
            viewModel.paginationState = .noMorePages
        } else if VCSReachabilityMonitor.isConnected {
            Task {
                await viewModel.loadNextPage(silentRefresh: true)
            }
        }
    }
    
    var body: some View {
        GeometryReader { _ in
            VStack(alignment: .center) {
                CurrentFilterView(
                    onDismiss: onDismiss,
                    fileTypeFilter: fileTypeFilter
                )
                
                switch viewState {
                case .error(let error):
                    ErrorView(error: error, onDismiss: onDismiss)
                    
                case .loading:
                    ProgressView()
                        .onAppear {
                            loadFilesForCurrentState()
                        }
                    
                default:
                    if !VCSReachabilityMonitor.isConnected && models.isEmpty {
                        OfflineEmptyView()
                    } else if models.isEmpty {
                        FilteredEmptyView()
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
                loadFilesForCurrentState()
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
                        onListEndReached()
                    }
            case .loadingNextPage:
                progressView
            case .noMorePages:
                EmptyView()
            }
        }
    }
}
