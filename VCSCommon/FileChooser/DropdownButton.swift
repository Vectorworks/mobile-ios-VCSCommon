//
//  File.swift
//
//
//  Created by Veneta Todorova on 29.07.24.
//

import Foundation
import SwiftUI

public struct DropdownButton: View {
    @Binding private var currentStorage: VCSStorageResponse
    @Binding private var showDropdown: Bool
    private var viewWidth: CGFloat
    
    public init(showDropdown: Binding<Bool>, currentStorage: Binding<VCSStorageResponse>, viewWidth: CGFloat) {
        self.viewWidth = viewWidth
        self._showDropdown = showDropdown
        self._currentStorage = currentStorage
    }
    
    public var body: some View {
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
        //This could be replaced with
//        Menu {
//            Button {
//            } label: {
//                Label("S3", systemImage: "s3Image")
//            }
//            ...
//        } label: {
//            Label(currentStorage.storageType.displayName, image: currentStorage.storageType.storageImageName)
//        }
    }
    
}
