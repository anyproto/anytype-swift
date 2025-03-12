//
//  ObjectPreviewView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 24.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import SwiftUI
import Services

struct ObjectPreviewView: View {
    @ObservedObject var viewModel: ObjectPreviewViewModel

    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: Loc.preview)
            mainSection
            featuredRealtionSection
        }
        .background(Color.Background.secondary)
        .padding(.horizontal, 20)
    }

    private var mainSection: some View {
        VStack(spacing: 0) {
            cardStyle(viewModel.objectPreviewModel.cardStyle)
                .divider()
            if viewModel.objectPreviewModel.isIconMenuVisible {
                iconSize(viewModel.objectPreviewModel.iconSize)
                    .divider()
            }
            if let coverRelation = viewModel.objectPreviewModel.coverRelation {
                featuredRelationsRow(coverRelation) { isEnabled in
                    viewModel.toggleFeaturedRelation(relation: coverRelation, isEnabled: isEnabled)
                }
            }

        }
    }

    private func iconSize(_ iconSize: BlockLink.IconSize) -> some View {
        menuRow(name: Loc.icon, value: iconSize.name) {
            viewModel.showIconMenu()
        }
    }

    private func cardStyle(_ cardStyle: BlockLink.CardStyle) -> some View {
        menuRow(name: Loc.previewLayout, value: cardStyle.name) {
            viewModel.showLayoutMenu()
        }
    }

    private func description(_ description: BlockLink.Description) -> some View {
        menuRow(name: Loc.description, icon: description.iconAsset, value: description.name) {
            viewModel.showDescriptionMenu()
        }
    }

    private var featuredRealtionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                Spacer()
                AnytypeText(Loc.featuredRelations, style: .caption1Regular)
                .foregroundColor(.Text.secondary)
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
            icon(imageAsset: item.iconAsset)

            if item.isLocked {
                AnytypeText(item.name, style: .uxBodyRegular)
                    .foregroundColor(.Text.primary)
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

    func icon(imageAsset: ImageAsset?) -> AnyView {
        if let imageAsset = imageAsset {
            return Group {
                Image(asset: imageAsset)
                    .foregroundColor(.Control.active)
                Spacer.fixedWidth(10)
            }.eraseToAnyView()
        } else {
            return EmptyView().eraseToAnyView()
        }
    }

    private func menuRow(name: String, icon: ImageAsset? = nil, value: String, onTap: @escaping () -> Void) -> some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 0) {
                if let icon = icon {
                    Image(asset: icon)
                        .foregroundColor(.Control.active)
                    Spacer.fixedWidth(10)
                }

                AnytypeText(name, style: .uxBodyRegular)
                    .foregroundColor(.Text.primary)
                Spacer()
                AnytypeText(value, style: .uxBodyRegular)
                .foregroundColor(.Text.secondary)
                Spacer.fixedWidth(10)
                Image(asset: .RightAttribute.disclosure)
            }
            .frame(height: 52)
        }
    }
}
