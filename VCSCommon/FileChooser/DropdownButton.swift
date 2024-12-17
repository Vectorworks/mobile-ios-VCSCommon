//
//  File.swift
//
//
//  Created by Veneta Todorova on 29.07.24.
//

import Foundation
import SwiftUI

struct DropdownButton: View {
    @State var currentStorage: VCSStorageResponse
    @Binding var showDropdown: Bool
    var viewWidth: CGFloat
    
    var body: some View {
        HStack {
            HStack {
                Image(currentStorage.storageType.storageImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Text(currentStorage.storageType.displayName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Image(systemName: "chevron.down")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10, height: 10)
                    .padding(2)
            }
        }
        .padding()
        .frame(width: viewWidth)
        .onTapGesture {
            showDropdown.toggle()
        }
    }
    
}
