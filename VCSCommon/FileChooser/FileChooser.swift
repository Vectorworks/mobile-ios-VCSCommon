import SwiftUI
import CocoaLumberjackSwift

public struct FileChooser: View {
    @State var path: [FileChooserRouteData] = []
    
    @State var fileTypeFilter: FileTypeFilter
    
    @State var rootRoute: FileChooserRouteData
    
    private var itemPickedCompletion: (RealmFile) -> Void
    
    private var onDismiss: (() -> Void)
    
    public init(
        fileTypeFilter: FileTypeFilter,
        itemPickedCompletion: @escaping (RealmFile) -> Void,
        onDismiss: @escaping (() -> Void)
    ) {
        let s3Storage = VCSUser.savedUser?.availableStorages.first(where: { $0.storageType == .S3 })
        if s3Storage == nil {
            self.rootRoute = .sharedWithMeRoot
        } else {
            self.rootRoute = .s3(MyFilesRouteData(resourceURI: s3Storage!.folderURI, displayName: s3Storage!.storageType.displayName))
        }
        self.fileTypeFilter = fileTypeFilter
        self.itemPickedCompletion = itemPickedCompletion
        self.onDismiss = onDismiss
    }
    
    private func onStorageChange(selectedStorage: VCSStorageResponse) {
        path.removeAll()
        if selectedStorage.storageType.isExternal {
            self.rootRoute = .externalStorage(MyFilesRouteData(resourceURI: selectedStorage.folderURI, displayName: selectedStorage.storageType.displayName))
        } else {
            self.rootRoute = .s3(MyFilesRouteData(resourceURI: selectedStorage.folderURI, displayName: selectedStorage.storageType.displayName))
        }
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
    
    private func onItemPicked(pickedModel: FileChooserModel) {
        guard let id = pickedModel.resourceId else {
            fatalError("ResourceId is nil.")
        }
        
        guard let filePicked = VCSFileResponse.realmStorage.getModelById(id: id) else {
            fatalError("Picked file not found.")
        }
        
        itemPickedCompletion(filePicked)
    }
    
    private var isInRoot: Bool {
        path.count == 0
    }
    
    @MainActor @ViewBuilder
    func buildView(for routeValue: FileChooserRouteData) -> some View {
        switch routeValue {
        case .s3(_), .externalStorage(_):
            CloudStorageFileChooser(
                fileTypeFilter: fileTypeFilter,
                itemPickedCompletion: onItemPicked,
                onDismiss: onDismiss,
                rootRoute: $rootRoute,
                currentRoute: routeValue
            )
        case .sharedWithMe(_), .sharedWithMeRoot :
            SharedWithMeFileChooser(
                fileTypeFilter: fileTypeFilter,
                itemPickedCompletion: onItemPicked,
                onDismiss: onDismiss,
                rootRoute: $rootRoute,
                currentRoute: routeValue
            )
        }
    }
    
    public var body: some View {
        GeometryReader { geometry in
            NavigationStack(path: $path) {
                CloudStorageFileChooser(
                    fileTypeFilter: fileTypeFilter,
                    itemPickedCompletion: onItemPicked,
                    onDismiss: onDismiss,
                    rootRoute: $rootRoute,
                    currentRoute: rootRoute
                )
                .configureNavigation(
                    path: $path,
                    rootRoute: $rootRoute,
                    isInRoot: isInRoot,
                    screenWidth: geometry.size.width,
                    onToolbarBackButtonPressed: onToolbarBackButtonPressed,
                    onStorageChange: onStorageChange
                )
                .navigationDestination(for: FileChooserRouteData.self) { routeValue in
                    buildView(for: routeValue)
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
}

struct NavigationConfigurationModifier: ViewModifier {
    @ObservedObject private var viewsLayoutSetting: ViewsLayoutSetting = ViewsLayoutSetting.listDefault
    
    @Binding var path: [FileChooserRouteData]
    
    @Binding var rootRoute: FileChooserRouteData
    
    @State var isInRoot: Bool
    
    @State var screenWidth: CGFloat
    
    @State private var showDropdown = false
    
    var onToolbarBackButtonPressed: () -> Void
    
    var onStorageChange: ((VCSStorageResponse) -> Void)
    
    private var previousFolderName: String {
        guard path.count >= 2 else { return "Back".vcsLocalized }
        return path[path.count - 2].displayName
    }
    
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(previousFolderName)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ToolbarBackButton(
                        label: previousFolderName,
                        viewWidth: screenWidth * 0.3,
                        onPress: onToolbarBackButtonPressed
                    )
                }
                
                ToolbarItem(placement: .principal) {
                    DropdownButton(
                        currentFolderName: Binding(
                            get: { path.last?.displayName ?? rootRoute.displayName },
                            set: { newValue in
                            }
                        ),
                        showDropdown: $showDropdown,
                        isInRoot: isInRoot,
                        viewWidth: UIDevice.current.userInterfaceIdiom == .pad ? screenWidth * 0.2 : screenWidth * 0.5
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
                    if showDropdown {
                        DropdownView(
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
        path: Binding<[FileChooserRouteData]>,
        rootRoute: Binding<FileChooserRouteData>,
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
