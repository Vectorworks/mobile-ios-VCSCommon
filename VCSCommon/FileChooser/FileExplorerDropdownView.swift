//
//  File.swift
//
//
//  Created by Veneta Todorova on 23.07.24.
//

import Foundation
import SwiftUI
import UIKit

struct FileExplorerDropdownView: View {
    @Binding var showDropdown: Bool
    @Binding var showBackDropdown: Bool
    @Binding var path: [FCRouteData]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(path.dropLast(), id: \.self) { folder in
                HStack{
                    Text(folder.breadcrumbsName)
                        .padding()
                        .truncationMode(.middle)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                        .padding()
                }
                .onTapGesture {
                    if let index = path.firstIndex(of: folder) {
                        path = Array(path.prefix(upTo: index + 1))
                    }
                    showDropdown = false
                    showBackDropdown = false
                }
                .frame(width: 200)
            }
        }
        .onTapGesture {
            showDropdown = false
            showBackDropdown = false
        }
        .background(colorScheme == .light ? Color.systemBackground : Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 50, x: 0, y: 5)
        .padding(4)
    }
}
