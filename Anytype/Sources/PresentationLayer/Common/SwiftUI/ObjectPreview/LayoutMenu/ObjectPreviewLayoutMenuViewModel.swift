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

    private var cardStyle: ObjectPreviewModel.CardStyle
    private let onSelect: (ObjectPreviewModel.CardStyle) -> Void

    // MARK: - Initializer

    init(cardStyle: ObjectPreviewModel.CardStyle,
         onSelect: @escaping (ObjectPreviewModel.CardStyle) -> Void) {
        self.onSelect = onSelect
        self.cardStyle = cardStyle
        self.updatePreviewFields(cardStyle)
    }

    func updatePreviewFields(_ cardStyle: ObjectPreviewModel.CardStyle) {
        items = buildObjectPreviewPopupItem(cardStyle: cardStyle)
    }

    func buildObjectPreviewPopupItem(cardStyle: ObjectPreviewModel.CardStyle) -> [CheckPopupItem] {
        ObjectPreviewModel.CardStyle.allCases.map { layout -> CheckPopupItem in
            let isSelected = cardStyle == layout
            return CheckPopupItem(id: layout.rawValue, icon: layout.iconName, title: layout.name, subtitle: nil, isSelected: isSelected)
        }
    }

    func onTap(itemId: String) {
        guard let layout = ObjectPreviewModel.CardStyle(rawValue: itemId) else { return }

        onSelect(layout)
        updatePreviewFields(layout)
    }
}
