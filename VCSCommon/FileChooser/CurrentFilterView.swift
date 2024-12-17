//
//  File.swift
//  
//
//  Created by Veneta Todorova on 18.07.24.
//
import Foundation
import SwiftUI

struct CurrentFilterView: View {
    
    var onDismiss: () -> Void
    
    @State var fileTypeFilter: FileTypeFilter
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(
            action: {
                onDismiss()
            },
            label: {
                HStack {
                    Image(fileTypeFilter.iconStr)
                        .foregroundColor(.VCSTeal)
                        .padding(EdgeInsets(top: 3, leading: 10, bottom: 3, trailing: 0))
                    Text(fileTypeFilter.titleStr)
                        .foregroundColor(.VCSTeal)
                        .font(.caption)
                        .fontWeight(.regular)
                        .padding(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 10))
                }
                .background(colorScheme == .light ? Color.black.opacity(0.1) : Color.white.opacity(0.1))
                .cornerRadius(10)
                .fixedSize()
            }
        )
    }
}
