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
    
    @State var shouldShowSharedWithMe: Bool
    
    var models: [FileChooserModel]
    
    var itemPickedCompletion: ((FileChooserModel) -> Void)?
    
    var onDismiss: (() -> Void)
        
    var isGuest: Bool = false
    
    private var adaptiveBackgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white
    }
    
    var body: some View {
        ScrollView {
            if shouldShowSharedWithMe && !isGuest {
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
            
            LazyVGrid(columns: [.init(.adaptive(minimum: K.Sizes.gridMinCellSize))], spacing: 20) {
                ForEach(models, id: \.resourceUri) { file in
                    Button {
                        onDismiss()
                        itemPickedCompletion?(file)
                    } label: {
                        GridItemView(
                            thumbnailURL: file.thumbnailUrl,
                            flags: file.flags,
                            name: file.name,
                            isFolder: false,
                            lastDateModified: file.lastDateModified
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
