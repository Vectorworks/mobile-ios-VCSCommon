import SwiftUI
import CocoaLumberjackSwift
import UIKit
import RealmSwift

struct SharedWithMeFileChooser: View {
    @ObservedResults(VCSUser.RealmModel.self, where: { $0.isLoggedIn == true }) var users
    
    @ObservedResults(SharedLink.RealmModel.self, filter: SharedWithMeViewModel.linksPredicate) var sharedLinksRawData

    @ObservedResults(VCSSharedWithMeAsset.RealmModel.self, where: { $0.sharedWithLogin == VCSUser.savedUser?.login ?? nil }) var availableFiles
    
    @ObservedObject private var VCSReachabilityMonitor = VCSReachability.default
    
    @StateObject private var viewModel: SharedWithMeViewModel
        
    private var isGuest: Bool {
        users.count == 0
    }
    
    init(fileTypeFilter: FileTypeFilter,
         itemPickedCompletion: @escaping (FileChooserModel) -> Void,
         onDismiss: @escaping (() -> Void),
         route: FileChooserRouteData) {
        let viewModel = SharedWithMeViewModel(
            fileTypeFilter: fileTypeFilter,
            route: Binding.constant(route),
            itemPickedCompletion: itemPickedCompletion,
            onDismiss: onDismiss)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        let models = viewModel.filterAndMapToModels(
            allSharedItems: availableFiles,
            sharedLinks: sharedLinksRawData,
            isGuest: isGuest,
            isConnected: VCSReachabilityMonitor.isConnected
        )
        
        FileChooserListView(
            viewModel: viewModel,
            models: models,
            itemPickedCompletion: viewModel.itemPickedCompletion,
            onDismiss: viewModel.onDismiss)
    }
}
