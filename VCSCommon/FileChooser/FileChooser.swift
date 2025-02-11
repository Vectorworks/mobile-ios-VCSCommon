import SwiftUI
import CocoaLumberjackSwift
import Realm
import RealmSwift

public struct FileChooser: View {
    @ObservedResults(VCSUser.RealmModel.self, where: { $0.isLoggedIn == true }) var users
    
    @ObservedObject private var viewsLayoutSetting: ViewsLayoutSetting = ViewsLayoutSetting.listDefault
    
    @ObservedObject private var VCSReachabilityMonitor = VCSReachability.default
    
    @State var fileTypeFilter: FileTypeFilter
    
    private var itemPickedCompletion: (RealmFile) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    public init(
        fileTypeFilter: FileTypeFilter,
        itemPickedCompletion: @escaping (RealmFile) -> Void
    ) {
        self.fileTypeFilter = fileTypeFilter
        self.itemPickedCompletion = itemPickedCompletion
    }
    
    private var isGuest: Bool {
        users.first?.entity == nil
    }
    
    private func onItemPicked(pickedModel: FileChooserModel) {
        guard let filePicked = VCSFileResponse.realmStorage.getModelById(id: pickedModel.resourceId) else {
            fatalError("Picked file not found.")
        }
        
        itemPickedCompletion(filePicked)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            FileChooserListView(
                fileTypeFilter: fileTypeFilter,
                itemPickedCompletion: onItemPicked,
                onDismiss: { dismiss() },
                isGuest: isGuest,
                isOnline: VCSReachabilityMonitor.isConnected
            )
            .navigationTitle(fileTypeFilter.titleStr)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    CurrentFilterView(
                        onDismiss: { dismiss() },
                        fileTypeFilter: fileTypeFilter
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
            .frame(maxWidth: .infinity)
            .tint(.VCSTeal)
        }
    }
}
