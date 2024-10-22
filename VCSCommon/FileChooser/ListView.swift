//
//  File.swift
//
//
//  Created by Veneta Todorova on 29.07.24.
//

import Foundation
import SwiftUI

struct ListView: View {
    @State var shouldShowSharedWithMe: Bool

    var models: [FileChooserModel]
        
    var itemPickedCompletion: ((FileChooserModel) -> Void)?
    
    var onDismiss: (() -> Void)
    
    var isGuest: Bool = false
    
    var body: some View {
        List {
            if shouldShowSharedWithMe && !isGuest {
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
            
            Section {
                ForEach(models, id: \.resourceUri) { file in
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
