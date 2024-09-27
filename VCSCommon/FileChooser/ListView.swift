//
//  File.swift
//
//
//  Created by Veneta Todorova on 29.07.24.
//

import Foundation
import SwiftUI

struct ListView: View {
    var models: [FileChooserModel]
    
    @Binding var currentRouteData: FileChooserRouteData
    
    var itemPickedCompletion: ((FileChooserModel) -> Void)?
    
    var onDismiss: (() -> Void)
    
    var isInRoot: Bool = false
    
    var isGuest: Bool = false
    
    private var files: [FileChooserModel] {
        models.filter { !$0.isFolder }
    }
    
    private var folders: [FileChooserModel] {
        models.filter { $0.isFolder }
    }
    
    var body: some View {
        List {
            if case .s3 = currentRouteData {
                if !isGuest && isInRoot {
                    Section {
                        NavigationLink(value: FileChooserRouteData.sharedWithMeRoot) {
                            ListItemView(
                                thumbnailURL: nil,
                                flags: nil,
                                name: "Shared with me".vcsLocalized,
                                isFolder: true,
                                isSharedWithMeFolder: true
                            )
                        }
                    }
                }
            }
            
            Section {
                ForEach(folders, id: \.resourceUri) { subfolder in
                    NavigationLink(value: subfolder.route) {
                        ListItemView(
                            thumbnailURL: nil,
                            flags: subfolder.flags,
                            name: subfolder.name,
                            isFolder: true
                        )
                    }
                }
            }
            
            Section {
                ForEach(files, id: \.resourceUri) { file in
                    Button {
                        onDismiss()
                        itemPickedCompletion?(file)
                    } label: {
                        ListItemView(
                            thumbnailURL: file.thumbnailUrl,
                            flags: file.flags,
                            name: file.name,
                            isFolder: false,
                            lastDateModified: file.lastDateModified
                        )
                    }
                }
            }
        }
    }
}
