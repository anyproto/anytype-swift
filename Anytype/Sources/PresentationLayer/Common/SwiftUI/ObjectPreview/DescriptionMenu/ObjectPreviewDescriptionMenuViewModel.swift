//
//  ObjectPreviewDescriptionMenuViewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 06.06.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import BlocksModels
import SwiftUI
import FloatingPanel

final class ObjectPreviewDescriptionMenuViewModel: CheckPopupViewViewModelProtocol {
    let title: String = "Description".localized

    @Published private(set) var items: [CheckPopupItem] = []

    // MARK: - Private variables

    private var description: ObjectPreviewModel.Description
    private let onSelect: (ObjectPreviewModel.Description) -> Void

    // MARK: - Initializer

    init(description: ObjectPreviewModel.Description,
         onSelect: @escaping (ObjectPreviewModel.Description) -> Void) {
        self.onSelect = onSelect
        self.description = description
        self.updatePreviewFields(description)
    }

    func updatePreviewFields(_ description: ObjectPreviewModel.Description) {
        items = buildObjectPreviewPopupItem(currentDescription: description)
    }

    func buildObjectPreviewPopupItem(currentDescription: ObjectPreviewModel.Description) -> [CheckPopupItem] {
        ObjectPreviewModel.Description.allCases.map { description -> CheckPopupItem in
            let isSelected = description == currentDescription
            return CheckPopupItem(id: description.rawValue,
                                  icon: nil,
                                  title: description.name,
                                  subtitle: description.subtitle,
                                  isSelected: isSelected)
        }
    }

    func onTap(itemId: String) {
        guard let description = ObjectPreviewModel.Description(rawValue: itemId) else { return }

        onSelect(description)
        updatePreviewFields(description)
    }
}
