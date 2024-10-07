//
//  File.swift
//
//
//  Created by Veneta Todorova on 3.09.24.
//

import SwiftUI
import CocoaLumberjackSwift
import UIKit
import RealmSwift

struct SharedWithMeFileChooser: View {
    @ObservedObject private var viewsLayoutSetting: ViewsLayoutSetting = ViewsLayoutSetting.listDefault
    
    @ObservedResults(VCSUser.RealmModel.self, where: { $0.isLoggedIn == true }) var users
    
    @ObservedResults(VCSSharedWithMeAsset.RealmModel.self, where: { $0.sharedParentFolder == "" && $0.sharedWithLogin == VCSUser.savedUser?.login ?? nil }) var sharedItemsRawData
    
    @ObservedResults(SharedLink.RealmModel.self, filter: SharedWithMeViewModel.sampleLinkPredicate) var sampleLinksRawData
    
    @ObservedResults(SharedLink.RealmModel.self, filter: SharedWithMeViewModel.linksPredicate) var sharedLinksRawData
    
    @ObservedResults(VCSFolderResponse.RealmModel.self) var currentFolderRawData
    
    @ObservedObject private var VCSReachabilityMonitor = VCSReachability.default
    
    @StateObject private var viewModel: SharedWithMeViewModel
    
    @Binding var rootRoute: FileChooserRouteData
    
    private var isGuest: Bool {
        users.count == 0
    }
    
    init(fileTypeFilter: FileTypeFilter,
         itemPickedCompletion: ((FileChooserModel) -> Void)?,
         onDismiss: @escaping (() -> Void),
         rootRoute: Binding<FileChooserRouteData>,
         currentRoute: FileChooserRouteData) {
        let viewModel = SharedWithMeViewModel(
            fileTypeFilter: fileTypeFilter,
            currentRoute: currentRoute,
            itemPickedCompletion: itemPickedCompletion,
            onDismiss: onDismiss)
        _viewModel = StateObject(wrappedValue: viewModel)
        self._rootRoute = rootRoute
    }
    
    var body: some View {
        GeometryReader { _ in
            VStack(alignment: .center) {
                CurrentFilterView(
                    onDismiss: viewModel.onDismiss,
                    fileTypeFilter: viewModel.fileTypeFilter
                )
                
                switch viewModel.viewState {
                case .loaded, .offline:
                    Group {
                        let models = viewModel.mapToModels(
                            sharedItems: sharedItemsRawData.map { $0.entity },
                            sampleFiles: sampleLinksRawData.compactMap {$0.entity.sharedAsset },
                            sharedLinks: sharedLinksRawData.compactMap { $0.entity.sharedAsset },
                            currentFolderResults: currentFolderRawData,
                            isGuest: isGuest
                        )
                        
                        switch viewsLayoutSetting.layout.asListLayoutCriteria {
                        case .list:
                            ListView(
                                models: models,
                                currentRouteData: $viewModel.currentRoute,
                                itemPickedCompletion: viewModel.itemPickedCompletion,
                                onDismiss: viewModel.onDismiss,
                                isInRoot: viewModel.isInRoot,
                                isGuest: isGuest
                            )
                        case .grid:
                            GridView(
                                models: models,
                                currentRouteData: $viewModel.currentRoute,
                                itemPickedCompletion: viewModel.itemPickedCompletion,
                                onDismiss: viewModel.onDismiss,
                                isInRoot: viewModel.isInRoot,
                                isGuest: isGuest
                            )
                        }
                    }
                    
                case .error(let error):
                    ErrorView(error: error, onDismiss: viewModel.onDismiss)
                    
                case .loading:
                    ProgressView()
                        .onAppear {
                            viewModel.loadFolder(isGuest: isGuest)
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .onChange(of: VCSReachabilityMonitor.isConnected) { _, isConnected in
                if isConnected {
                    viewModel.loadFolder(isGuest: isGuest)
                } else {
                    viewModel.viewState = .offline
                }
            }
        }
    }
}
