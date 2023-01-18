//
//  ObjectPreviewLayoutViewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 30.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import BlocksModels
import SwiftUI
import FloatingPanel

final class ObjectPreviewLayoutMenuViewModel: CheckPopupViewViewModelProtocol {
    let title = Loc.previewLayout
    @Published private(set) var items: [CheckPopupItem] = []

    // MARK: - Private variables

    private var cardStyle: BlockLink.CardStyle
    private let onSelect: (BlockLink.CardStyle) -> Void

    // MARK: - Initializer

    init(cardStyle: BlockLink.CardStyle,
         onSelect: @escaping (BlockLink.CardStyle) -> Void) {
        self.onSelect = onSelect
        self.cardStyle = cardStyle
        self.updatePreviewFields(cardStyle)
    }

    func updatePreviewFields(_ cardStyle: BlockLink.CardStyle) {
        items = buildObjectPreviewPopupItem(cardStyle: cardStyle)
    }

    func buildObjectPreviewPopupItem(cardStyle: BlockLink.CardStyle) -> [CheckPopupItem] {
        BlockLink.CardStyle.allCases.map { layout -> CheckPopupItem in
            CheckPopupItem(
                id: String(layout.rawValue),
                iconAsset: layout.iconAsset,
                title: layout.name,
                subtitle: nil,
                isSelected: cardStyle == layout,
                onTap: { [weak self] in self?.onTap(item: layout) }
            )
        }
    }

    private func onTap(item: BlockLink.CardStyle) {
        onSelect(item)
        updatePreviewFields(item)
    }
}
