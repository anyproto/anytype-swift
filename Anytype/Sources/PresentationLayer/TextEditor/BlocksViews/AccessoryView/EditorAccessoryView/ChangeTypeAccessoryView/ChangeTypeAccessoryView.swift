//
//  ChangeTypeAccessoryView.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 20.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct ChangeTypeAccessoryItemViewModel: Identifiable {
    let id: String
    let title: String
    let image: Image
    let action: () -> Void
}

struct ChangeTypeAccessoryView: View {
    let items: [ChangeTypeAccessoryItemViewModel]

    var body: some View {
        HStack(spacing: 32) {
            ForEach(items) {
                TypeView(image: $0.image, title: $0.title)
            }
        }
    }
}

private struct TypeView: View {
    let image: Image
    let title: String

    var body: some View {
        VStack {
            imageView
            AnytypeText(title, style: .caption2Regular, color: .textSecondary)
        }
    }

    private var imageView: some View {
        image
            .renderingMode(.template)
            .foregroundColor(Color.grayscale50)
            .frame(width: 48, height: 48, alignment: .center)
            .background(Color.grayscale10)
            .cornerRadius(12)
            .eraseToAnyView()
    }
}

struct TypeView_Previews: PreviewProvider {
    static var previews: some View {
        TypeView(image: Image.main.search, title: "Search")
    }
}

struct ChangeTypeAccessoryView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeTypeAccessoryView(items: [.searchItem, .draftItem])
    }
}

fileprivate extension ChangeTypeAccessoryItemViewModel {
    static var searchItem: Self {
        .init(id: "1", title: "Search", image: Image.main.search, action: {})
    }

    static var draftItem: Self {
        .init(id: "1", title: "Draft", image: Image.main.search, action: {})
    }
}
