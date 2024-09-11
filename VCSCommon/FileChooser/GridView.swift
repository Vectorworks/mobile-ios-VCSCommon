//
//  File.swift
//  
//
//  Created by Veneta Todorova on 29.07.24.
//

import Foundation
import SwiftUI

struct GridView: View {
    @Environment(\.colorScheme) var colorScheme

    var models: [FileChooserModel]
    
    @Binding var currentRouteData: FileChooserRouteData

    var itemPickedCompletion: ((FileChooserModel) -> Void)?
    
    var onDismiss: (() -> Void)
    
    var isInRoot: Bool = false
    
    var isGuest: Bool = false
    
    private var adaptiveBackgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white
    }
    
    private var files: [FileChooserModel] {
        models.filter { !$0.isFolder }
    }
    
    private var folders: [FileChooserModel] {
        models.filter { $0.isFolder }
    }
    
    var body: some View {
        ScrollView {
            if case .s3(_) = currentRouteData {
                if !isGuest && isInRoot {
                    NavigationLink(value: FileChooserRouteData.sharedWithMeRoot) {
                        VStack {
                            HStack {
                                ListItemView(
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
                    }
                }
            }
            
            LazyVGrid(columns: [GridItem(.flexible())]) {
                ForEach(folders, id: \.resourceUri) { subfolder in
                    NavigationLink(value: subfolder.route) {
                        HStack {
                            ListItemView(
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
                ForEach(files, id: \.resourceUri) { file in
                    Button {
                        onDismiss()
                        itemPickedCompletion?(file)
                    } label: {
                        GridItemView(
                            thumbnailURL: file.thumbnailUrl,
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

