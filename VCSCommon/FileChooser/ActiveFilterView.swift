//
//  File.swift
//  
//
//  Created by Veneta Todorova on 18.07.24.
//

import Foundation
import SwiftUI

struct ActiveFilterView: View {
    @State var fileTypeFilter: FileTypeFilter
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            Image(fileTypeFilter.iconStr)
                .foregroundColor(.VCSTeal)
                .padding(5)
            Text(fileTypeFilter.titleStr)
                .foregroundColor(.VCSTeal)
                .font(.subheadline)
                .fontWeight(.regular)
            Spacer()
            
            Image(systemName: "xmark")
                .foregroundColor(colorScheme == .light ? .gray : .white)
                .padding(5)
        }
        .background(colorScheme == .light ? Color.black.opacity(0.1) : Color.white.opacity(0.1))
        .cornerRadius(10)
        .fixedSize()
    }
    
}
