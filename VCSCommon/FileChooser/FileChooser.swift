import SwiftUI
import CocoaLumberjackSwift
import Realm
import RealmSwift

public struct FileChooser: View {
    @ObservedResults(VCSUser.RealmModel.self, where: { $0.isLoggedIn == true }) var users
    
    @ObservedObject private var viewsLayoutSetting: ViewsLayoutSetting = ViewsLayoutSetting.listDefault
    
    @ObservedObject private var VCSReachabilityMonitor = VCSReachability.default
        
    @State var fileTypeFilter: FileTypeFilter
    
    @State var rootRoute: FileChooserRouteData
        
    @State private var showDropdown = false
            
    private var itemPickedCompletion: (RealmFile) -> Void
    
    @Environment(\.dismiss) private var dismiss

//    private var onDismiss: (() -> Void)
    
    public init(
        fileTypeFilter: FileTypeFilter,
        itemPickedCompletion: @escaping (RealmFile) -> Void
//        onDismiss: @escaping (() -> Void)
    ) {
        let s3Storage = VCSUser.savedUser?.availableStorages.first(where: { $0.storageType == .S3 })
        if s3Storage == nil {
            self.rootRoute = .sharedWithMe
        } else {
            self.rootRoute = .s3(MyFilesRouteData(displayName: s3Storage!.storageType.displayName))
        }
        self.fileTypeFilter = fileTypeFilter
        self.itemPickedCompletion = itemPickedCompletion
//        self.onDismiss = onDismiss
    }
    
    private var isGuest: Bool {
        users.first?.entity == nil
    }
    
    private var availableStorages: [VCSStorageResponse] {
        VCSUser.savedUser?.availableStorages ?? []
    }
    
    private func onStorageChange(selectedStorage: VCSStorageResponse) {
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
    
    private func onItemPicked(pickedModel: FileChooserModel) {
        guard let filePicked = VCSFileResponse.realmStorage.getModelById(id: pickedModel.resourceId) else {
            fatalError("Picked file not found.")
        }
        
        itemPickedCompletion(filePicked)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            NavigationView {
                FileChooserListView(
                    fileTypeFilter: fileTypeFilter,
                    itemPickedCompletion: onItemPicked,
                    onDismiss: { dismiss() },
                    route: $rootRoute,
                    isGuest: isGuest,
                    isOnline: VCSReachabilityMonitor.isConnected
                )
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        ToolbarBackButton(
                            label: "Back".vcsLocalized,
                            viewWidth: geometry.size.width * 0.3,
                            onPress: { dismiss() }
                        )
                    }
                    
                    ToolbarItem(placement: .principal) {
                        DropdownButton(
                            currentFolderName: Binding(
                                get: { rootRoute.displayName },
                                set: { _ in
                                }
                            ),
                            showDropdown: $showDropdown,
                            showDropdownArrow: !availableStorages.isEmpty,
                            viewWidth: UIDevice.current.userInterfaceIdiom == .pad ? geometry.size.width * 0.2 : geometry.size.width * 0.5
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
                                availableStorages: availableStorages,
                                onStorageChange: self.onStorageChange
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        }
                    }
                )
                .frame(maxWidth: .infinity)
                .tint(.VCSTeal)
            }
            .navigationBarHidden(true)
        }
    }
}
