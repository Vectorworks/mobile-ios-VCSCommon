import SwiftUI
import CocoaLumberjackSwift
import UIKit
import RealmSwift

struct FileChooserListView: View {
    @ObservedObject private var viewsLayoutSetting: ViewsLayoutSetting = ViewsLayoutSetting.listDefault
    
    @ObservedObject private var VCSReachabilityMonitor = VCSReachability.default
    
    @StateObject private var viewModel: FileChooserViewModel
    
    @State private var isOnline: Bool
    
    @State private var expandedIndex: Int?
    
    @State private var showDropdown = false
    
    @State private var route: FileChooserRouteData
    
    @ObservedResults(VCSFileResponse.RealmModel.self, where: { $0.ownerLogin == VCSUser.savedUser?.login ?? "nil" }) var allUserFiles
    
    @ObservedResults(SharedLink.RealmModel.self, filter: FileChooserViewModel.linksPredicate) var sharedLinksRawData
    
    @ObservedResults(VCSSharedWithMeAsset.RealmModel.self, where: { $0.sharedWithLogin == VCSUser.savedUser?.login ?? nil }) var allSharedItems
    
    private var itemPickedCompletion: (FileChooserModel) -> Void
    
    private var onDismiss: () -> Void
    
    private var availableStorages: [VCSStorageResponse] {
        VCSUser.savedUser?.availableStorages ?? []
    }
    
    init(fileTypeFilter: FileTypeFilter,
         itemPickedCompletion: @escaping (FileChooserModel) -> Void,
         onDismiss: @escaping (() -> Void),
         isGuest: Bool,
         isOnline: Bool) {
        let s3Storage = VCSUser.savedUser?.availableStorages.first(where: { $0.storageType == .S3 })
        let route : FileChooserRouteData = isGuest ? .sharedWithMe : .s3(MyFilesRouteData(displayName: s3Storage!.storageType.displayName))
        self.route = route
        self.isOnline = isOnline
        self.itemPickedCompletion = itemPickedCompletion
        self.onDismiss = onDismiss
        
        let viewModel = FileChooserViewModel(
            fileTypeFilter: fileTypeFilter,
            mainRoute: route,
            isGuest: isGuest)
        
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private func onStorageChange(selectedStorage: VCSStorageResponse) {
        switch selectedStorage.storageType {
            
        case .S3:
            self.route = .s3(MyFilesRouteData(displayName: selectedStorage.storageType.displayName))
            
        case .DROPBOX:
            self.route = .dropbox(MyFilesRouteData(displayName: selectedStorage.storageType.displayName))
            
        case .GOOGLE_DRIVE:
            self.route = .googleDrive(MyFilesRouteData(displayName: selectedStorage.storageType.displayName))
            
        case .ONE_DRIVE:
            self.route = .oneDrive(MyFilesRouteData(displayName: selectedStorage.storageType.displayName))
            
        default:
            fatalError("Unsupported storage type.")
        }
    }
    
    private func shouldShowPaginationProgressSpinner(section: RouteSection) -> Bool {
        if viewModel.getState(for: section) == .noMorePages || !isOnline || viewModel.isGuest {
            false
        } else {
            true
        }
    }
    
    private func filterDatabaseFiles(section: RouteSection, isOnline: Bool) -> [FileChooserModel] {
        if (section.shouldRefresh) {
            switch section.route {
            case .s3, .dropbox, .googleDrive, .oneDrive:
                viewModel.filterAndMapToModelsForCurrentStorage(allFiles: allUserFiles,
                                                                section: section,
                                                                isOnline: isOnline
                )
                
            case .sharedWithMe:
                viewModel.filterAndMapToModelsForSharedWithMe(allSharedItems: allSharedItems,
                                                              sharedLinks: sharedLinksRawData,
                                                              isOnline: isOnline,
                                                              sectionIndex: section.index
                )
                
            case .sampleFiles:
                viewModel.populateSampleFilesSectionForGuest(isOnline: isOnline,
                                                             sectionIndex: section.index)
            }
        }
        
        return viewModel.sections[section.index].models
    }
    
    private var currentStorage: VCSStorageResponse? {
        availableStorages.first(where: { $0.storageType == route.storageType })
    }
    
    func content(geometry: GeometryProxy) -> some View {
        VStack(alignment: .center) {
            if let storage = currentStorage {
                DropdownButton(
                    currentStorage: Binding(get: { storage }, set: { _ in }),
                    availableStorages: availableStorages,
                    onStorageChange: onStorageChange
                )
            }
            
            switch viewModel.viewState {
            case .error(let error):
                VCSErrorView(error: error, onDismiss: onDismiss)
                
            default:
                VStack(spacing: 8) {
                    ForEach(viewModel.sections) { section in
                        let maxHeight = expandedIndex == section.index ? geometry.size.height * 0.7 : geometry.size.height * 0.1
                        
                        collapsibleListView(
                            section: section,
                            maxHeight: maxHeight,
                            isOnline: isOnline
                        )
                    }
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            content(geometry: geometry)
            .frame(maxWidth: .infinity)
            .onChange(of: route) { _, newRoute in
                Task {
                    await viewModel.updateSections(newMainRoute: newRoute)
                }
            }
            .onChange(of: VCSReachabilityMonitor.isConnected) { _, newValue in
                isOnline = newValue
                Task {
                    viewModel.setSectionsShouldRefresh()
                }
            }
            .onChange(of: viewModel.viewState) { _, newValue in
                Task {
                    viewModel.setSectionsShouldRefresh()
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadInitialData()
                }
            }.onDisappear {
                viewModel.resetSections()
            }
        }
    }
    
    func collapsibleListView(section: RouteSection, maxHeight: CGFloat, isOnline: Bool) -> some View {
        VStack(spacing: 0) {
            Button(action: {
                if expandedIndex == section.index {
                    expandedIndex = nil
                } else {
                    expandedIndex = section.index
                }
            }) {
                HStack {
                    Text(section.route.displayName)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    Spacer()
                    
                    Image(systemName: expandedIndex == section.index ? "chevron.down" : "chevron.right")
                        .font(.headline)
                        .padding()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if self.expandedIndex == section.index {
                let models = filterDatabaseFiles(section: section, isOnline: isOnline)
                
                Group {
                    Divider()
                        .padding(.leading)
                        .padding(.trailing)
                    if !section.isInitialDataLoaded && isOnline {
                        ProgressView()
                    } else if !isOnline && (!section.isInitialDataLoaded || section.models.isEmpty) {
                        OfflineEmptyView()
                    } else if section.models.isEmpty {
                        FilteredEmptyView()
                    } else {
                        switch viewsLayoutSetting.layout.asListLayoutCriteria {
                        case .list:
                            listView(maxHeight: maxHeight, section: section, models: models, isOnline: isOnline)
                            
                        case .grid:
                            lazyVGridView(maxHeight: maxHeight, section: section, models: models, isOnline: isOnline)
                        }
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
        .padding()
    }
    
    func listView(maxHeight: CGFloat, section: RouteSection, models: [FileChooserModel], isOnline: Bool) -> some View {
        List {
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
                    .listRowBackground(Color(.systemGray6))
                    .id(file.id)
                }
            }
            
            if shouldShowPaginationProgressSpinner(section: section) {
                paginationProgressView(section: section, isOnline: isOnline)
            }
        }
        .frame(maxHeight: maxHeight)
        .scrollContentBackground(.hidden)
    }
    
    func lazyVGridView(maxHeight: CGFloat, section: RouteSection, models: [FileChooserModel], isOnline: Bool) -> some View {
        ScrollView {
            LazyVGrid(columns: [.init(.adaptive(minimum: ViewConstants.Sizes.gridMinCellWidth, maximum: ViewConstants.Sizes.gridMaxCellWidth))], spacing: 20) {
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
                    }
                }
                if  shouldShowPaginationProgressSpinner(section: section) {
                    paginationProgressView(section: section, isOnline: isOnline)
                }
            }
        }
        .frame(maxHeight: maxHeight)
    }
    
    func paginationProgressView(section: RouteSection, isOnline: Bool) -> some View {
        let progressView: AnyView
        
        switch viewsLayoutSetting.layout.asListLayoutCriteria {
        case .list:
            progressView = AnyView(
                HStack {
                    Spacer()
                    ProgressView()
                        .background(Color.clear)
                    Spacer()
                }
                    .background(Color.clear)
            )
        case .grid:
            progressView = AnyView(ProgressView())
        }
        
        return Group {
            switch viewModel.getState(for: section) {
            case .hasNextPage:
                progressView
                    .onAppear {
                        Task {
                            if isOnline && !viewModel.isGuest {
                                await viewModel.loadNextPage(section: section)
                            }
                        }
                    }
            case .loading:
                progressView
            case .noMorePages:
                EmptyView()
            }
        }
    }
}
