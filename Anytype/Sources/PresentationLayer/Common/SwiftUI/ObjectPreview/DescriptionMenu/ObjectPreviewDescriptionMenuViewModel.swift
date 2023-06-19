//
//  ObjectPreviewDescriptionMenuViewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 06.06.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Services
import SwiftUI
import FloatingPanel

final class ObjectPreviewDescriptionMenuViewModel: CheckPopupViewViewModelProtocol {
    let title: String = Loc.description

    @Published private(set) var items: [CheckPopupItem] = []

    // MARK: - Private variables

    private var description: BlockLink.Description
    private let onSelect: (BlockLink.Description) -> Void

    // MARK: - Initializer

    init(description: BlockLink.Description,
         onSelect: @escaping (BlockLink.Description) -> Void) {
        self.onSelect = onSelect
        self.description = description
        self.updatePreviewFields(description)
    }

    func updatePreviewFields(_ description: BlockLink.Description) {
        items = buildObjectPreviewPopupItem(currentDescription: description)
    }

    func buildObjectPreviewPopupItem(currentDescription: BlockLink.Description) -> [CheckPopupItem] {
        BlockLink.Description.allCases.map { description -> CheckPopupItem in
            let isSelected = description == currentDescription
            return CheckPopupItem(id: String(description.rawValue),
                                  iconAsset: nil,
                                  title: description.name,
                                  subtitle: description.subtitle,
                                  isSelected: isSelected,
                                  onTap: { [weak self] in self?.onTap(item: description) }
            )
        }
    }

    private func onTap(item: BlockLink.Description) {

        onSelect(item)
        updatePreviewFields(item)
    }
}
