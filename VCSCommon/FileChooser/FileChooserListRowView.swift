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

struct FileChooserListRow: View {
    @State var thumbnailURL: URL?
    @State var flags: VCSFlagsResponse?
    @State var name: String
    @State var isFolder: Bool
    
    var placeholderImageIconString: String {
        if isFolder {
            K.VCSIconStrings.folder
        } else {
            K.VCSIconStrings.file
        }
    }
    
    var body: some View {
        HStack {
            WebImage(url: thumbnailURL) { image in
                image.resizable()
            } placeholder: {
                Image(placeholderImageIconString)
                    .resizable()
                    .foregroundStyle(.gray)
            }
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
            .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    if flags?.hasWarning == true {
                        Image(K.VCSIconStrings.status_warning)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    Text(name)
                        .listCellTextModifier()
                }
            }
            .padding(.leading)
        }
    }
}
