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
    let title = "Preview layout".localized
    @Published private(set) var items: [CheckPopupItem] = []

    // MARK: - Private variables

    private var cardStyle: ObjectPreviewViewSection.MainSectionItem.CardStyle
    private let objectPreviewModelBuilder = ObjectPreivewSectionBuilder()
    private let onSelect: (ObjectPreviewViewSection.MainSectionItem.CardStyle) -> Void

    // MARK: - Initializer

    init(cardStyle: ObjectPreviewViewSection.MainSectionItem.CardStyle,
         onSelect: @escaping (ObjectPreviewViewSection.MainSectionItem.CardStyle) -> Void) {
        self.onSelect = onSelect
        self.cardStyle = cardStyle
        self.updatePreviewFields(cardStyle)
    }

    func updatePreviewFields(_ cardStyle: ObjectPreviewViewSection.MainSectionItem.CardStyle) {
        items = buildObjectPreviewPopupItem(cardStyle: cardStyle)
    }

    func buildObjectPreviewPopupItem(cardStyle: ObjectPreviewViewSection.MainSectionItem.CardStyle) -> [CheckPopupItem] {
        ObjectPreviewViewSection.MainSectionItem.CardStyle.allCases.map { layout -> CheckPopupItem in
            let isSelected = cardStyle == layout
            return CheckPopupItem(id: layout.rawValue, icon: layout.iconName, title: layout.name, subtitle: nil, isSelected: isSelected)
        }
    }

    func onTap(itemId: String) {
        guard let layout = ObjectPreviewViewSection.MainSectionItem.CardStyle(rawValue: itemId) else { return }

        onSelect(layout)
        updatePreviewFields(layout)
    }
}
