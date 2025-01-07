//
//  File.swift
//  
//
//  Created by Veneta Todorova on 18.07.24.
//
import Foundation
import SwiftUI

struct CurrentFilterView: View {
    typealias Colors = ViewConstants.Colors
    
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
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.VCSTeal)
                    Text(fileTypeFilter.titleStr)
                        .foregroundColor(.VCSTeal)
                        .font(.caption)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Colors.buttonBackground(for: colorScheme))
                .cornerRadius(5)
            }
        )
    }
}
