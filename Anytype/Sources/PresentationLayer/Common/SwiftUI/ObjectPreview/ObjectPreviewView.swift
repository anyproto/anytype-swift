//
//  ObjectPreviewView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 24.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import SwiftUI
import BlocksModels

struct ObjectPreviewView: View {
    @ObservedObject var viewModel: ObjectPreviewViewModel

    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: "Preview".localized)
            mainSection
            featuredRealtionSection
        }
        .background(Color.backgroundSecondary)
        .padding(.horizontal, 20)
    }

    private var mainSection: some View {
        VStack(spacing: 0) {
            cardStyle(viewModel.objectPreviewModel.cardStyle)
                .divider()
            iconSize(viewModel.objectPreviewModel.iconSize)
                .divider()
        }
    }

    private func iconSize(_ iconSize: ObjectPreviewModel.IconSize) -> some View {
        menuRow(name: "Icon".localized, value: iconSize.name) {
            viewModel.showIconMenu()
        }
    }

    private func cardStyle(_ cardStyle: ObjectPreviewModel.CardStyle) -> some View {
        menuRow(name: "Preview layout".localized, value: cardStyle.name) {
            viewModel.showLayoutMenu()
        }
    }

    private func description(_ description: ObjectPreviewModel.Description) -> some View {
        menuRow(name: "Description".localized, icon: description.iconName, value: description.name) {
            viewModel.showDescriptionMenu()
        }
    }

    private var featuredRealtionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                Spacer()
                AnytypeText("Featured relations".localized, style: .caption1Regular, color: .textSecondary)
                    .padding(.bottom, 8)
            }
            .frame(height: 52)

            ForEach(viewModel.objectPreviewModel.relations.indices, id: \.self) { index in
                let item = viewModel.objectPreviewModel.relations[index]

                switch item {
                case .relation(let relation):
                    featuredRelationsRow(relation) { isEnabled in
                        viewModel.toggleFeaturedRelation(relation: relation, isEnabled: isEnabled)
                    }
                    .divider()
                case .description:
                    description(viewModel.objectPreviewModel.description)
                        .divider()
                }
            }
        }
    }

    private func featuredRelationsRow(_ item: ObjectPreviewModel.Relation, onTap: @escaping (_ isEnabled: Bool) -> Void) -> some View {
        HStack(spacing: 0) {
            Image.createImage(item.iconName)
                .frame(width: 24, height: 24)
            Spacer.fixedWidth(10)

            if item.isLocked {
                AnytypeText(item.name.localized, style: .uxBodyRegular, color: .textPrimary)
            } else {
                AnytypeToggle(
                    title: item.name,
                    isOn: item.isEnabled
                ) {
                    onTap($0)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(height: 52)
    }

    private func menuRow(name: String, icon: String? = nil, value: String, onTap: @escaping () -> Void) -> some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 0) {
                if let icon = icon {
                    Image.createImage(icon)
                        .frame(width: 24, height: 24)
                    Spacer.fixedWidth(10)
                }

                AnytypeText(name, style: .uxBodyRegular, color: .textPrimary)
                Spacer()
                AnytypeText(value, style: .uxBodyRegular, color: .textSecondary)
                Spacer.fixedWidth(10)
                Image.arrow
            }
            .frame(height: 52)
        }
    }
}

struct ObjectPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let router = ObjectPreviewRouter(viewController: UIViewController())
        let viewModel = ObjectPreviewViewModel(objectPreviewModel: .init(iconSize: .medium, cardStyle: .text, description: .none, relations: []),
                                               router: router,
                                               onSelect: {_ in })
        ObjectPreviewView(viewModel: viewModel)
    }
}
