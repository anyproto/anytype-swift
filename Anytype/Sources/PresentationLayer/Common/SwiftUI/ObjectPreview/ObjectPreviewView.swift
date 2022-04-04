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
            ForEach(viewModel.objectPreviewSections.main) { item in
                mainSectionRow(item) {
                    switch item.value {
                    case .icon:
                        viewModel.showIconMenu()
                    case .layout:
                        viewModel.showLayoutMenu()
                    }
                }
                .divider()
            }
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

            ForEach(viewModel.objectPreviewSections.featuredRelation) { item in
                featuredRelationsRow(item) { isEnabled in
                    // TODO: will be impled in next pr
                }
                .divider()
            }
        }
    }

    private func featuredRelationsRow(_ item: ObjectPreviewViewFeaturedSectionItem, onTap: @escaping (_ isEnabled: Bool) -> Void) -> some View {
        HStack(spacing: 0) {
            item.icon
                .frame(width: 24, height: 24)
            Spacer.fixedWidth(10)
            AnytypeToggle(
                title: item.name,
                isOn: item.isEnabled
            ) {
                onTap($0)
            }
        }
        .frame(height: 52)
    }

    private func mainSectionRow(_ item: ObjectPreviewViewMainSectionItem, onTap: @escaping () -> Void) -> some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 0) {
                AnytypeText(item.name, style: .uxBodyRegular, color: .textPrimary)
                Spacer()
                AnytypeText(item.value.name, style: .uxBodyRegular, color: .textSecondary)
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
        let viewModel = ObjectPreviewViewModel(featuredRelationsByIds: [:], fields: .init(), router: router)
        ObjectPreviewView(viewModel: viewModel)
    }
}
