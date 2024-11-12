import SwiftUI
import CocoaLumberjackSwift
import Realm

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
            self.rootRoute = .s3(MyFilesRouteData(displayName: s3Storage!.storageType.displayName))
        }
        self.fileTypeFilter = fileTypeFilter
        self.itemPickedCompletion = itemPickedCompletion
        self.onDismiss = onDismiss
    }
    
    private func onStorageChange(selectedStorage: VCSStorageResponse) {
        path.removeAll()
        switch selectedStorage.storageType {
            
        case .S3:
            self.rootRoute = .s3(MyFilesRouteData(displayName: selectedStorage.storageType.displayName))
            
        case .DROPBOX:
            self.rootRoute = .dropbox(MyFilesRouteData(displayName: selectedStorage.storageType.displayName))
            
        case .GOOGLE_DRIVE:
            self.rootRoute = .googleDrive(MyFilesRouteData(displayName: selectedStorage.storageType.displayName))
            
        case .ONE_DRIVE:
            self.rootRoute = .oneDrive(MyFilesRouteData(displayName: selectedStorage.storageType.displayName))
            
        default:
            fatalError("Unsupported storage type.")
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
        guard let filePicked = VCSFileResponse.realmStorage.getModelById(id: pickedModel.resourceId) else {
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
        case .s3, .dropbox, .googleDrive, .oneDrive:
            CloudStorageFileChooser(
                fileTypeFilter: fileTypeFilter,
                itemPickedCompletion: onItemPicked,
                onDismiss: onDismiss,
                route: $rootRoute
            )
        case .sharedWithMeRoot:
            SharedWithMeFileChooser(
                fileTypeFilter: fileTypeFilter,
                itemPickedCompletion: onItemPicked,
                onDismiss: onDismiss,
                route: routeValue
            )
        }
    }
    
    public var body: some View {
        GeometryReader { geometry in
            NavigationStack(path: $path) {
                buildView(for: rootRoute)
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
    
    private var availableStorages: [VCSStorageResponse] {
        VCSUser.savedUser?.availableStorages ?? []
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
                            set: { _ in
                            }
                        ),
                        showDropdown: $showDropdown,
                        showDropdownArrow: !path.isEmpty || !availableStorages.isEmpty,
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
                            availableStorages: availableStorages,
                            onStorageChange: self.onStorageChange
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                }
            )
            .onChange(of: path, { showDropdown = false })
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
