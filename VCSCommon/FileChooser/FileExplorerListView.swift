//
//  File.swift
//
//
//  Created by Veneta Todorova on 29.07.24.
//

import Foundation
import SwiftUI

struct FileExplorerListView: View {
    @State var folders: [VCSFolderResponse]
    
    @State var files: [VCSFileResponse]
    
    var itemPickedCompletion: ((VCSFileResponse) -> Void)?
    
    var getThumbnailURL: ((VCSFileResponse) -> URL?)

    var onDismiss: (() -> Void)
    
    var body: some View {
        List {
            ForEach(folders, id: \.rID) { subfolder in
                NavigationLink(value: FCRouteData(resourceURI: subfolder.resourceURI, breadcrumbsName: subfolder.name)) {
                    FileChooserListRow(
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
                    FileChooserListRow(
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
