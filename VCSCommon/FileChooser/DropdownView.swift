//
//  File.swift
//
//
//  Created by Veneta Todorova on 23.07.24.
//

import Foundation
import SwiftUI
import UIKit

struct DropdownView: View {
    @Binding var showDropdown: Bool
    @Binding var path: [FileChooserRouteData]
    var availableStorages: [VCSStorageResponse]
    @Environment(\.colorScheme) var colorScheme
    
    var onStorageChange: ((VCSStorageResponse) -> Void)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack {
                ForEach(path.dropLast(), id: \.self) { route in
                    VStack {
                        HStack{
                            Text(route.displayName)
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
                            if let index = path.firstIndex(of: route) {
                                path = Array(path.prefix(upTo: index + 1))
                            }
                            showDropdown = false
                        }
                        if path.firstIndex(of: route) ?? 0 < path.count - 2 {
                            Divider()
                        }
                    }
                    .frame(width: 200)
                }
            }
            .background(colorScheme == .light ? Color.white : Color(.systemGray6))
            
            VStack {
                ForEach(VCSUser.savedUser?.availableStorages ?? [], id: \.storageType) { (currentStorage: VCSStorageResponse) in
                    VStack {
                        HStack {
                            Image(currentStorage.storageType.storageImageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .padding()
                            Text(currentStorage.storageType.displayName)
                                .truncationMode(.middle)
                            Spacer()
                        }
                        Divider()
                    }
                    .frame(width: 200)
                    .onTapGesture {
                        showDropdown.toggle()
                        onStorageChange(currentStorage)
                    }
                }
            }
            .background(colorScheme == .light ? Color.white : Color(.systemGray6))
        }
        .onTapGesture {
            showDropdown = false
        }
        .background(colorScheme == .light ? Color.systemBackground : Color.black)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 50, x: 0, y: 5)
        .padding(4)
    }
}
