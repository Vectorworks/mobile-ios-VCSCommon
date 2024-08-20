//
//  File.swift
//  
//
//  Created by Veneta Todorova on 29.07.24.
//

import Foundation
import SwiftUI

struct FileExplorerGridView: View {
    @Binding var folders: [VCSFolderResponse]
    
    @Binding var files: [VCSFileResponse]
    
    var itemPickedCompletion: ((VCSFileResponse) -> Void)?
    
    var getThumbnailURL: ((VCSFileResponse) -> URL?)

    var onDismiss: (() -> Void)
    
    private var columns: [GridItem] {
        return [
            .init(.adaptive(minimum: 200))
        ]
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(folders, id: \.rID) { subfolder in
                    NavigationLink(value: FCRouteData(resourceURI: subfolder.resourceURI, breadcrumbsName: subfolder.name)) {
                        FileChooserGridItemView(
                            thumbnailURL: nil,
                            flags: subfolder.flags,
                            name: subfolder.name,
                            isFolder: true
                        )
                    }
                }
                
                ForEach(files, id: \.rID) { file in
                    Button {
                        onDismiss()
                        itemPickedCompletion?(file)
                    } label: {
                        FileChooserGridItemView(
                            thumbnailURL: getThumbnailURL(file),
                            flags: file.flags,
                            name: file.name,
                            isFolder: false
                        )
                    }
                }
            }
        }
    }
}

