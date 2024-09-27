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
    @State var thumbnailURL: URL?
    @State var flags: VCSFlagsResponse?
    @State var name: String
    @State var isFolder: Bool
    @State var isSharedWithMeFolder: Bool = false
    @State var lastDateModified: Date?
    
    var placeholderImageIconString: String {
        if isFolder {
            K.VCSIconStrings.folder
        } else {
            K.VCSIconStrings.file
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            WebImage(url: thumbnailURL) { image in
                image.resizable()
                    .frame(width: K.Sizes.gridCellImageBackgroundSize, height: K.Sizes.gridCellImageBackgroundSize)
            } placeholder: {
                Group {
                    if isSharedWithMeFolder {
                        Image("shared-with-me")
                            .resizable()
                            .foregroundStyle(.gray)
                            .frame(width: 50, height: 50)
                    } else {
                        Image(placeholderImageIconString)
                            .resizable()
                            .foregroundStyle(.gray)
                            .frame(width: K.Sizes.gridCellImageSize, height: K.Sizes.gridCellImageSize)
                            .padding(15)
                    }
                }
            }
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
            .cornerRadius(5)
            
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
                HStack {
                    Text(lastDateModified?.formatted() ?? "")
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, 10)
    }
}
