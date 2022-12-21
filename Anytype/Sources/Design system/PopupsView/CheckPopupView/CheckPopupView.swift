//
//  CheckPopupView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 01.04.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import SwiftUI
import BlocksModels

struct CheckPopupView<ViewModel: CheckPopupViewViewModelProtocol>: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ViewModel
    @State private var scrollViewContentSize: CGSize = .zero

    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: viewModel.title)
            mainSection
        }
        .background(Color.BackgroundNew.secondary)
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
                AnytypeText(item.title, style: .uxBodyRegular, color: .TextNew.primary)

                if let subtitle = item.subtitle {
                    AnytypeText(subtitle, style: .caption1Regular, color: .TextNew.secondary)
                }
            }
            Spacer()

            if item.isSelected {
                Image(asset: .optionChecked).frame(width: 24, height: 24).foregroundColor(.Button.selected)
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
