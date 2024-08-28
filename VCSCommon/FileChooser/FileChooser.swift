import SwiftUI
import CocoaLumberjackSwift

public struct FileChooser: View {
    @State var path: [FCRouteData] = []
    
    @State var fileTypeFilter: FileTypeFilter
    
    @State var rootRoute: FCRouteData
    
    private var itemPickedCompletion: ((VCSFileResponse) -> Void)?
    
    private var onDismiss: (() -> Void)
    
    public init(
        fileTypeFilter: FileTypeFilter,
        itemPickedCompletion: ((VCSFileResponse) -> Void)? = nil,
        onDismiss: @escaping (() -> Void)
    ) {
        let s3Storage = VCSUser.savedUser?.availableStorages.first(where: { $0.storageType == .S3 })
        if s3Storage == nil {
            self.rootRoute = FCRouteData(resourceURI: "todo", breadcrumbsName: "todo")
        } else {
            self.rootRoute = FCRouteData(resourceURI: s3Storage!.folderURI, breadcrumbsName: s3Storage!.storageType.displayName)
        }
        self.fileTypeFilter = fileTypeFilter
        self.itemPickedCompletion = itemPickedCompletion
        self.onDismiss = onDismiss
    }
    
    private func onStorageChange(selectedStorage: VCSStorageResponse) {
        path.removeAll()
        self.rootRoute = FCRouteData(resourceURI: selectedStorage.folderURI, breadcrumbsName: selectedStorage.storageType.displayName)
    }
    
    private func onToolbarBackButtonPressed() {
        if isInRoot {
            onDismiss()
        } else {
            if !path.isEmpty {
                path.removeLast()
            }
        }
    }
    
    private var isInRoot: Bool {
        path.count == 0
    }
    
    public var body: some View {
        GeometryReader { geometry in
            NavigationStack(path: $path) {
                FileExplorerView(
                    fileTypeFilter: fileTypeFilter,
                    path: $path,
                    currentFolderResourceUri: nil,
                    itemPickedCompletion: itemPickedCompletion,
                    onDismiss: onDismiss,
                    rootRoute: $rootRoute
                )
                .navigationDestination(for: FCRouteData.self) { routeValue in
                    FileExplorerView(
                        fileTypeFilter: fileTypeFilter,
                        path: $path,
                        currentFolderResourceUri: routeValue.resourceURI,
                        itemPickedCompletion: itemPickedCompletion,
                        onDismiss: onDismiss,
                        rootRoute: $rootRoute
                    )
                    .configureNavigation(
                        path: $path,
                        rootRoute: $rootRoute,
                        isInRoot: isInRoot,
                        screenWidth: geometry.size.width,
                        onToolbarBackButtonPressed: onToolbarBackButtonPressed,
                        onStorageChange: onStorageChange
                    )
                }
                .configureNavigation(
                    path: $path,
                    rootRoute: $rootRoute,
                    isInRoot: isInRoot,
                    screenWidth: geometry.size.width,
                    onToolbarBackButtonPressed: onToolbarBackButtonPressed,
                    onStorageChange: onStorageChange
                )
            }
        }
    }
}

struct NavigationConfigurationModifier: ViewModifier {
    @ObservedObject private var viewsLayoutSetting: ViewsLayoutSetting = ViewsLayoutSetting.listDefault
    
    @Binding var path: [FCRouteData]
    
    @Binding var rootRoute: FCRouteData
    
    @State var isInRoot: Bool
    
    @State var screenWidth: CGFloat
    
    @State private var showDropdown = false
    
    var onToolbarBackButtonPressed: () -> Void
    
    var onStorageChange: ((VCSStorageResponse) -> Void)
    
    private var previousFolderName: String {
        guard path.count >= 2 else { return "Back".vcsLocalized }
        return path[path.count - 2].breadcrumbsName
    }
    
    func body(content: Content) -> some View {
        content
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
                        viewWidth: UIDevice.current.userInterfaceIdiom == .pad ? screenWidth * 0.2 : screenWidth * 0.5,
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
            .tint(.VCSTeal)
    }
}

extension View {
    @MainActor func configureNavigation(
        path: Binding<[FCRouteData]>,
        rootRoute: Binding<FCRouteData>,
        isInRoot: Bool,
        screenWidth: CGFloat,
        onToolbarBackButtonPressed: @escaping () -> Void,
        onStorageChange: @escaping ((VCSStorageResponse) -> Void)
    ) -> some View {
        self.modifier(NavigationConfigurationModifier(
            path: path,
            rootRoute: rootRoute,
            isInRoot: isInRoot,
            screenWidth: screenWidth,
            onToolbarBackButtonPressed: onToolbarBackButtonPressed,
            onStorageChange: onStorageChange
        ))
    }
}
