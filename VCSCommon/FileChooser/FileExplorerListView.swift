//
//  File.swift
//
//
//  Created by Veneta Todorova on 29.07.24.
//

import Foundation
import SwiftUI

struct FileExplorerListView: View {
    @Binding var folders: [VCSFolderResponse]
    
    @Binding var files: [VCSFileResponse]
    
    var itemPickedCompletion: ((VCSFileResponse) -> Void)?
    
    var getThumbnailURL: ((VCSFileResponse) -> URL?)
    
    var onDismiss: (() -> Void)
    
    var isInRoot: Bool = false
    
    var isGuest: Bool = false
    
    var body: some View {
        List {
            if isInRoot && !isGuest {
                Section {
                    FileChooserListRow(
                        thumbnailURL: nil,
                        flags: nil,
                        name: "Shared with me".vcsLocalized,
                        isFolder: true,
                        isSharedWithMeFolder: true
                    )
                }
            }
            
            Section {
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
            }
            
            Section {
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
}
