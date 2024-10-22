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
            
    @ObservedResults(SharedLink.RealmModel.self, where: { $0.RealmID == VCSServer.default.serverURLString.stringByAppendingPath(
        path: "/links/:samples/:metadata/")}) var sampleFiles
    
    @ObservedResults(VCSSharedWithMeAsset.RealmModel.self, where: { $0.sharedWithLogin == VCSUser.savedUser?.login ?? nil }) var availableFiles
    
    @ObservedObject private var VCSReachabilityMonitor = VCSReachability.default
    
    @StateObject private var viewModel: SharedWithMeViewModel
    
    @Binding var route: FileChooserRouteData
    
    private var isGuest: Bool {
        users.count == 0
    }
    
    init(fileTypeFilter: FileTypeFilter,
         itemPickedCompletion: ((FileChooserModel) -> Void)?,
         onDismiss: @escaping (() -> Void),
         route: Binding<FileChooserRouteData>) {
        let viewModel = SharedWithMeViewModel(
            fileTypeFilter: fileTypeFilter,
            itemPickedCompletion: itemPickedCompletion,
            onDismiss: onDismiss)
        _viewModel = StateObject(wrappedValue: viewModel)
        self._route = route
    }
    
    func loadFilesForCurrentState(isConnected: Bool) {
        if isConnected && !isGuest {
            Task {
                await viewModel.loadFilesWithCurrentFilter(storageType: nil)
            }
        } else {
            viewModel.viewState = isGuest ? .loading : .offline
            if isGuest {
                viewModel.loadSampleFiles()
            }
        }
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
                    let models = viewModel.filterAndMapToModels(
                        allSharedItems: availableFiles,
                        sampleFiles: Array(sampleFiles),
                        isGuest: isGuest
                    )
                    
                    Group {
                        switch viewsLayoutSetting.layout.asListLayoutCriteria {
                        case .list:
                            ListView(
                                shouldShowSharedWithMe: false,
                                models: models,
                                itemPickedCompletion: viewModel.itemPickedCompletion,
                                onDismiss: viewModel.onDismiss,
                                isGuest: isGuest
                            )
                        case .grid:
                            GridView(
                                shouldShowSharedWithMe: false,
                                models: models,
                                itemPickedCompletion: viewModel.itemPickedCompletion,
                                onDismiss: viewModel.onDismiss,
                                isGuest: isGuest
                            )
                        }
                    }
                    
                case .error(let error):
                    ErrorView(error: error, onDismiss: viewModel.onDismiss)
                    
                case .loading:
                    ProgressView()
                        .onAppear {
                            let isConnected = VCSReachabilityMonitor.isConnected
                            loadFilesForCurrentState(isConnected : isConnected)
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .onChange(of: VCSReachabilityMonitor.isConnected) { _, isConnected in
                loadFilesForCurrentState(isConnected: isConnected)
            }
        }
    }
}
