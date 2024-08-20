import SwiftUI
import CocoaLumberjackSwift
import UIKit

struct FileExplorerView: View {
    @ObservedObject private var viewsLayoutSetting: ViewsLayoutSetting = ViewsLayoutSetting.listDefault
    
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var viewModel: FileExplorerViewModel
    
    @Binding var path: [FCRouteData]
    
    @Binding var rootRoute: FCRouteData
    
    @State private var showDropdown = false
        
    @State var currentFolderResourceUri: String?
    
    var itemPickedCompletion: ((VCSFileResponse) -> Void)?
    
    var onDismiss: (() -> Void)
    
    var onStorageChange: ((VCSStorageResponse) -> Void)
        
    private var isInRoot: Bool {
        path.count == 0
    }
    
    private var previousFolderName: String {
        guard path.count >= 2 else { return "Back".vcsLocalized }
        return path[path.count - 2].breadcrumbsName
    }
    
    init(fileTypeFilter: FileTypeFilter,
         path: Binding<[FCRouteData]>,
         currentFolderResourceUri: String?,
         itemPickedCompletion: ((VCSFileResponse) -> Void)?,
         onDismiss: @escaping (() -> Void),
         onStorageChange: @escaping ((VCSStorageResponse) -> Void),
         rootRoute: Binding<FCRouteData>) {
        _viewModel = StateObject(wrappedValue: FileExplorerViewModel(fileTypeFilter: fileTypeFilter))
        self._path = path
        self.currentFolderResourceUri = currentFolderResourceUri
        self.itemPickedCompletion = itemPickedCompletion
        self.onDismiss = onDismiss
        self.onStorageChange = onStorageChange
        self._rootRoute = rootRoute
    }
    
    func onToolbarBackButtonPressed() {
        if isInRoot {
            onDismiss()
        } else {
            if !path.isEmpty {
                path.removeLast()
            }
        }
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
                                onDismiss: onDismiss
                            )
                        case .grid :
                            FileExplorerGridView(
                                folders: $viewModel.sortedFolders,
                                files: $viewModel.sortedFiles,
                                itemPickedCompletion: itemPickedCompletion,
                                getThumbnailURL: viewModel.getThumbnailURL,
                                onDismiss: onDismiss
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
            .onChange(of: rootRoute) { newValue in
                if isInRoot {
                    viewModel.loadFolder(resourceUri: newValue.resourceURI)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(previousFolderName)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    FileExplorerToolbarBackButton(
                        label: previousFolderName,
                        onPress: onToolbarBackButtonPressed
                    )
                }
                
                ToolbarItem(placement: .principal) {
                    FileExplorerDropdownButton(
                        currentFolderName: path.last?.breadcrumbsName ?? rootRoute.breadcrumbsName,
                        isInRoot: isInRoot,
                        viewWidth: UIDevice.current.userInterfaceIdiom == .pad ? geometry.size.width * 0.2 : geometry.size.width * 0.5,
                        showDropdown: $showDropdown
                    )
                    .id(path.last?.breadcrumbsName ?? rootRoute.breadcrumbsName)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker(selection: $viewsLayoutSetting.layout, label: Text("Style")) {
                        Label(ListLayoutCriteria.grid.buttonName, image: ListLayoutCriteria.grid.buttonImageName)
                            .tag(ListLayoutCriteria.grid.rawValue)
                        Label(ListLayoutCriteria.list.buttonName, image: ListLayoutCriteria.list.buttonImageName)
                            .tag(ListLayoutCriteria.list.rawValue)
                    }
                    .tint(Color.label)
                }
            }
            .overlay(
                Group {
                    if showDropdown {
                        FileExplorerDropdownView(
                            showDropdown: $showDropdown,
                            path: $path,
                            onStorageChange: self.onStorageChange
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                }
            )
            .frame(maxWidth: .infinity)
        }
    }
}
