//
//  File.swift
//  
//
//  Created by Veneta Todorova on 29.07.24.
//

import Foundation
import SwiftUI

struct FileExplorerGridView: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var folders: [VCSFolderResponse]
    
    @Binding var files: [VCSFileResponse]
    
    var itemPickedCompletion: ((VCSFileResponse) -> Void)?
    
    var getThumbnailURL: ((VCSFileResponse) -> URL?)
    
    var onDismiss: (() -> Void)
    
    var isInRoot: Bool = false
    
    var isGuest: Bool = false
    
    private var adaptiveBackgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white
    }
    
    var body: some View {
        ScrollView {
            if isInRoot && !isGuest {
                HStack {
                    FileChooserListRow(
                        thumbnailURL: nil,
                        flags: nil,
                        name: "Shared with me".vcsLocalized,
                        isFolder: true,
                        isSharedWithMeFolder: true
                    )
                    .padding()
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(adaptiveBackgroundColor)
                .cornerRadius(10)
                .padding(10)
                
                Divider()
                    .background(Color.white)
                    .frame(height: 1)
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
            }
            
            LazyVGrid(columns: [GridItem(.flexible())]) {
                ForEach(folders, id: \.rID) { subfolder in
                    NavigationLink(value: FCRouteData(resourceURI: subfolder.resourceURI, breadcrumbsName: subfolder.name)) {
                        HStack {
                            FileChooserListRow(
                                thumbnailURL: nil,
                                flags: subfolder.flags,
                                name: subfolder.name,
                                isFolder: true
                            )
                            .padding()
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(adaptiveBackgroundColor)
                        .cornerRadius(10)
                        .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                    }
                }
            }
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
            
            LazyVGrid(columns: [.init(.adaptive(minimum: K.Sizes.gridMinCellSize))], spacing: 20) {
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
                        .padding(8)
                        .background(adaptiveBackgroundColor)
                        .cornerRadius(10)
                    }
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

