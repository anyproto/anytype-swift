//
//  CodeBlockContentConfiguration.swift
//  AnyType
//
//  Created by Denis Batvinkin on 05.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import BlocksModels
import UIKit


/// Content configuration for text blocks
struct CodeBlockContentConfiguration {
    /// View model
    weak var viewModel: CodeBlockViewModel?

    /// Block information
    var information: BlockInformationModel
    private(set) var isSelected: Bool = false

    init(_ blockViewModel: CodeBlockViewModel) {
        self.information = .init(information: blockViewModel.information)
    }
}

extension CodeBlockContentConfiguration: UIContentConfiguration {

    func makeContentView() -> UIView & UIContentView {
        let view: CodeBlockContentView = .init(configuration: self)
        viewModel?.addContextMenuIfNeeded(view)
        return view
    }

    func updated(for state: UIConfigurationState) -> CodeBlockContentConfiguration {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfig = self

        updatedConfig.isSelected = state.isSelected
        return updatedConfig
    }
}

extension CodeBlockContentConfiguration: Hashable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.information == rhs.information && lhs.isSelected == rhs.isSelected
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(information)
        hasher.combine(isSelected)
    }
}
