//
//  File.swift
//
//
//  Created by Veneta Todorova on 24.07.24.
//

import Foundation
import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct GridItemView: View {
    typealias Sizes = ViewConstants.Sizes

    @Environment(\.colorScheme) var colorScheme
    @State var thumbnailURL: URL?
    @State var flags: VCSFlagsResponse?
    @State var name: String
    @State var isFolder: Bool
    @State var lastDateModified: Date?
    @State var size: String?
    
    var placeholderImageIconString: String {
        if isFolder {
            K.VCSIconStrings.folder
        } else {
            K.VCSIconStrings.file
        }
    }
    
    private var adaptiveBackgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            WebImage(url: thumbnailURL) { image in
                image.resizable()
                    .frame(
                        minWidth: Sizes.gridCellMinImageSize,
                        maxWidth: Sizes.gridCellMaxImageSize,
                        minHeight: Sizes.gridCellMinImageSize,
                        maxHeight: Sizes.gridCellMaxImageSize
                    )
            } placeholder: {
                Group {
                    Image(placeholderImageIconString)
                        .resizable()
                        .foregroundStyle(.gray)
                        .frame(
                            minWidth: Sizes.gridCellMinImageSize,
                            maxWidth: Sizes.gridCellMaxImageSize,
                            minHeight: Sizes.gridCellMinImageSize,
                            maxHeight: Sizes.gridCellMaxImageSize
                        )
                }
            }
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
            .cornerRadius(5)
            .padding(Sizes.gridCellImagePadding)
            
            VStack(alignment: .leading) {
                HStack {
                    if flags?.hasWarning == true {
                        Image(K.VCSIconStrings.status_warning)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    Text(name)
                        .gridCellTextModifier()
                    Spacer()
                }
                if let sizeString = size {
                    HStack {
                        Text(sizeString)
                            .font(.subheadline)
                            .foregroundColor(Color(.systemGray))
                        Spacer()
                    }
                }
                HStack {
                    Text(lastDateModified?.formatted() ?? "")
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minWidth: Sizes.gridMinCellWidth, maxWidth: Sizes.gridMaxCellWidth)
        .padding(8)
        .background(adaptiveBackgroundColor)
        .cornerRadius(10)
    }
}
