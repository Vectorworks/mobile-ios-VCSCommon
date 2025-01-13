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
    private var availableStorages: [VCSStorageResponse]
    private var onStorageChange: ((VCSStorageResponse) -> Void)
    
    public init(
        currentStorage: Binding<VCSStorageResponse>,
        availableStorages: [VCSStorageResponse],
        onStorageChange: @escaping ((VCSStorageResponse) -> Void)) {
            self._currentStorage = currentStorage
            self.availableStorages = availableStorages
            self.onStorageChange = onStorageChange
        }
    
    public var body: some View {
        Menu {
            ForEach(availableStorages) { storage in
                Button {
                    onStorageChange(storage)
                } label: {
                    Label(storage.storageType.displayName,
                          image: storage.storageType.storageImageName)
                }
            }
        } label: {
            HStack {
                Label(currentStorage.storageType.displayName, image: currentStorage.storageType.storageImageName)
                    .foregroundColor(.primary)
                
                Image(systemName: "chevron.down")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10, height: 10)
                    .padding(2)
                    .foregroundColor(.primary)
            }
        }
    }
    
}
