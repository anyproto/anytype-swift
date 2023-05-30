//
//  CheckPopupView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 01.04.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import SwiftUI
import Services

struct CheckPopupView<ViewModel: CheckPopupViewViewModelProtocol>: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: viewModel.title)
            mainSection
        }
        .background(Color.Background.secondary)
        .padding(.horizontal, 20)
    }

    private var mainSection: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.items) { item in
                Button {
                    presentationMode.wrappedValue.dismiss()
                    item.onTap()
                } label: {
                    mainSectionRow(item)
                }
                .divider()
            }
        }
    }

    private func mainSectionRow(_ item: CheckPopupItem) -> some View {
        HStack(spacing: 0) {
            if let iconAsset = item.iconAsset {
                Image(asset: iconAsset)
                Spacer.fixedWidth(12)
            }

            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(item.title, style: .uxBodyRegular, color: .Text.primary)

                if let subtitle = item.subtitle {
                    AnytypeText(subtitle, style: .caption1Regular, color: .Text.secondary)
                }
            }
            Spacer()

            if item.isSelected {
                Image(asset: .X24.tick).foregroundColor(.Button.button)
            }
        }
        .frame(height: 52)
    }
}

struct CheckPopupView_Previews: PreviewProvider {
    final class CheckPopupTestViewModel: CheckPopupViewViewModelProtocol {
        let title: String = "Title"
        
        func onTap(itemId: String) {
        }

        var items: [CheckPopupItem] = [
            .init(id: "1", iconAsset: .text, title: "Some title", subtitle: "Long subtitle", isSelected: true, onTap: {}),
            .init(id: "2", iconAsset: .text, title: "Other title", subtitle: "Long subtitle", isSelected: false, onTap: {})
        ]
    }

    static var previews: some View {
        let viewModel = CheckPopupTestViewModel()
        CheckPopupView(viewModel: viewModel)
    }
}
