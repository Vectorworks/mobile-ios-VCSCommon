import SwiftUI
import CocoaLumberjackSwift
import UIKit

struct FileExplorerView: View {
    @ObservedObject private var viewsLayoutSetting: ViewsLayoutSetting = ViewsLayoutSetting.listDefault
    
    @StateObject private var viewModel: FileExplorerViewModel
    
    @State private var showDropdown = false
    
    @State private var showBackDropdown = false
    
    @Binding var path: [FCRouteData]
    
    var itemPickedCompletion: ((VCSFileResponse) -> Void)?
    
    var onDismiss: (() -> Void)
    
    @Environment(\.colorScheme) var colorScheme
    
    
    init(fileTypeFilter: FileTypeFilter,
         path: Binding<[FCRouteData]>,
         currentFolderResourceUri: String,
         itemPickedCompletion: ((VCSFileResponse) -> Void)?,
         onDismiss: @escaping (() -> Void)) {
        _viewModel = StateObject(wrappedValue: FileExplorerViewModel(fileTypeFilter: fileTypeFilter, currentFolderResourceUri: currentFolderResourceUri))
        self._path = path
        self.itemPickedCompletion = itemPickedCompletion
        self.onDismiss = onDismiss
    }
    
    private var isInRoot: Bool {
        path.count == 1
    }
    
    private var previousFolderName: String {
        guard path.count >= 2 else { return "" }
        return path[path.count - 2].breadcrumbsName
    }
    
    private var currentFolderName: String {
        guard let currentFolderName = path.last?.breadcrumbsName else {
            fatalError("Path is invalid.")
        }
        return currentFolderName
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
                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? geometry.size.width * 0.2 : geometry.size.width * 0.5)
                
                switch viewModel.resultFolder {
                case .success(_):
                    Group {
                        switch viewsLayoutSetting.layout.asListLayoutCriteria {
                        case .list :
                            FileExplorerListView(
                                folders: viewModel.sortedFolders,
                                files: viewModel.sortedFiles,
                                itemPickedCompletion: itemPickedCompletion,
                                getThumbnailURL: viewModel.getThumbnailURL,
                                onDismiss: onDismiss
                            )
                        case .grid :
                            FileExplorerGridView(
                                folders: viewModel.sortedFolders,
                                files: viewModel.sortedFiles,
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
                        .onAppear{
                            viewModel.loadFolder()
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(previousFolderName)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                if !isInRoot {
                    ToolbarItem(placement: .topBarLeading) {
                        FileExplorerToolbarBackButton(
                            label: previousFolderName,
                            onPress: {
                                if !path.isEmpty {
                                    path.removeLast()
                                }
                            },
                            onLongPress: {
                                showBackDropdown.toggle()
                            }
                        )
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    FileExplorerDropdownButton(
                        shouldDisplayDropdown: path.count > 1,
                        currentFolderName: currentFolderName,
                        isInRoot: isInRoot,
                        viewWidth: UIDevice.current.userInterfaceIdiom == .pad ? geometry.size.width * 0.2 : geometry.size.width * 0.5,
                        showDropdown: $showDropdown
                    )
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
                    if showDropdown && path.count > 1 {
                        FileExplorerDropdownView(
                            showDropdown: $showDropdown,
                            showBackDropdown: $showBackDropdown,
                            path: $path
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    
                    if showBackDropdown {
                        FileExplorerDropdownView(
                            showDropdown: $showDropdown,
                            showBackDropdown: $showBackDropdown,
                            path: $path
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                }
            )
        }
    }
}
