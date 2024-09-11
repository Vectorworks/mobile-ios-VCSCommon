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
    
    @ObservedResults(VCSSharedWithMeAsset.RealmModel.self, filter: SharedWithMeViewModel.rootSharedWithMePredicate) var sharedItemsRawData
    
    @ObservedResults(SharedLink.RealmModel.self, filter: SharedWithMeViewModel.sampleLinkPredicate) var sampleLinksRawData
    
    @ObservedResults(SharedLink.RealmModel.self, filter: SharedWithMeViewModel.linksPredicate) var sharedLinksRawData
    
    @StateObject private var viewModel: SharedWithMeViewModel
    
    @Binding var rootRoute: FileChooserRouteData
    
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
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Button(
                    action: {
                        viewModel.onDismiss()
                    },
                    label : {
                        ActiveFilterView(fileTypeFilter: viewModel.fileTypeFilter)
                    }
                )
                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? geometry.size.width * 0.2 : geometry.size.width * 0.4)
                
                switch viewModel.viewState {
                case .loaded:
                    Group {
                        let models = viewModel.mapToModels(
                            sharedItems: sharedItemsRawData.map {$0.entity}
                        )
                        
                        switch viewsLayoutSetting.layout.asListLayoutCriteria {
                        case .list :
                            ListView(
                                models: models,
                                currentRouteData: $viewModel.currentRoute,
                                itemPickedCompletion: viewModel.itemPickedCompletion,
                                onDismiss: viewModel.onDismiss,
                                isInRoot: viewModel.isInRoot
                            )
                        case .grid :
                            GridView(
                                models: models,
                                currentRouteData: $viewModel.currentRoute,
                                itemPickedCompletion: viewModel.itemPickedCompletion,
                                onDismiss: viewModel.onDismiss,
                                isInRoot: viewModel.isInRoot
                            )
                        }
                    }
                    
                case .error(let error):
                    ErrorView(error: error, onDismiss: viewModel.onDismiss)
                    
                case .loading:
                    ProgressView()
                        .onAppear {
                            let resourceUri: String?
                            if case .sharedWithMeRoot = viewModel.currentRoute {
                                resourceUri = nil
                            } else {
                                resourceUri = viewModel.currentRoute.resourceUri
                            }
                            viewModel.loadFolder(resourceUri: resourceUri)
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .onChange(of: rootRoute) { oldValue, newValue in
                viewModel.loadFolder(resourceUri: newValue.resourceUri)
            }
        }
    }
}
