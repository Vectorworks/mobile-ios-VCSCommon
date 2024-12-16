//
//  File.swift
//
//
//  Created by Veneta Todorova on 29.07.24.
//

import Foundation
import SwiftUI

struct DropdownButton: View {
    @Binding var currentFolderName: String
    @Binding var showDropdown: Bool
    var showDropdownArrow: Bool
    var viewWidth: CGFloat
    
    var body: some View {
        HStack {
            Text(currentFolderName)
                .foregroundStyle(Color.VCSTeal)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
            
            if showDropdownArrow {
                Image(systemName: "chevron.down")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10, height: 10)
                    .foregroundColor(Color.VCSTeal)
                    .background(
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 16, height: 16)
                    )
                    .padding(2)
            }
        }
        .frame(width: viewWidth)
        .onTapGesture {
            showDropdown.toggle()
        }
    }
    
}
