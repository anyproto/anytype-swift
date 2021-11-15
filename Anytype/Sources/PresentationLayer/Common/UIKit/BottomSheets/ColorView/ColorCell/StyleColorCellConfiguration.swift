//
//  StyleColorCellContentConfiguration.swift
//  AnyType
//
//  Created by Denis Batvinkin on 27.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit


struct StyleColorCellContentConfiguration: UIContentConfiguration, Hashable {
    let colorItem: ColorView.ColorItem
    var isSelected: Bool = false

    func makeContentView() -> UIView & UIContentView {
        return StyleColorContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfig = self

        updatedConfig.isSelected = state.isSelected
        return updatedConfig
    }
}
