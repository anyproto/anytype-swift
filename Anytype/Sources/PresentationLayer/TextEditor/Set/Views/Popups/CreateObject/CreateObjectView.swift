//
//  CreateObjectView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 20.05.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import SwiftUI
import AnytypeCore

struct CreateObjectView: View {
    @State private var text: String = .empty

    var body: some View {
        HStack(spacing: 16) {
            AnytypeTextField(style: .previewTitle1Medium, placeholder: "Untitled".localized, text: $text)
            Spacer(minLength: 10)

            Button {

            } label: {
                Image.set.openObject
            }
        }
        .padding(.init(top: 21, leading: 20, bottom: 31, trailing: 20))
    }
}
