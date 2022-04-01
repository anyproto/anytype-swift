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

final class ObjectPreviewPopupViewModel: CheckPopuViewViewModelProtocol {
    @Published var items: [CheckPopupItem] = []

    // MARK: - Private variables

    private let objectPreviewModelBuilder = ObjectPreivewSectionBuilder()

    // MARK: - Initializer

    init(objectPreviewFields: ObjectPreviewFields) {
        self.updatePreviewFields(objectPreviewFields)
    }

    func updatePreviewFields(_ objectPreviewFields: ObjectPreviewFields) {
        items = buildObjectPreviewPopupItem(objectPreviewFields: objectPreviewFields)
    }

    func buildObjectPreviewPopupItem(objectPreviewFields: ObjectPreviewFields) -> [CheckPopupItem] {
        ObjectPreviewFields.Layout.allCases.map { layout -> CheckPopupItem in
            let isSelected = objectPreviewFields.layout == layout
            return CheckPopupItem(id: layout.rawValue, icon: layout.iconName, title: layout.name, subtitle: nil, isSelected: isSelected)
        }
    }

    func onTap(item: CheckPopupItem) {
        guard let layout = ObjectPreviewFields.Layout(rawValue: item.id) else { return }

        // TODO: here will be fileds service
    }
}
