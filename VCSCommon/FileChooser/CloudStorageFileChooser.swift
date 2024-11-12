import SwiftUI
import CocoaLumberjackSwift
import UIKit
import RealmSwift

struct CloudStorageFileChooser: View {
    @ObservedObject private var VCSReachabilityMonitor = VCSReachability.default
        
    @ObservedResults(VCSFileResponse.RealmModel.self, where: { $0.ownerLogin == VCSUser.savedUser?.login ?? "nil" }) var allFiles
    
    @StateObject private var viewModel: CloudStorageViewModel
        
    var itemPickedCompletion: (FileChooserModel) -> Void
    
    var onDismiss: () -> Void
    
    init(fileTypeFilter: FileTypeFilter,
         itemPickedCompletion: @escaping (FileChooserModel) -> Void,
         onDismiss: @escaping (() -> Void),
         route: Binding<FileChooserRouteData>) {
        _viewModel = StateObject(wrappedValue: CloudStorageViewModel(
            fileTypeFilter: fileTypeFilter,
            route: route
        ))
        self.itemPickedCompletion = itemPickedCompletion
        self.onDismiss = onDismiss
    }

    var body: some View {
        let models = viewModel.filterAndMapToModels(
            allFiles: allFiles,
            isConnected: VCSReachabilityMonitor.isConnected
        )
        FileChooserListView(
            viewModel: viewModel,
            models: models,
            itemPickedCompletion: itemPickedCompletion,
            onDismiss: onDismiss)
    }
}
