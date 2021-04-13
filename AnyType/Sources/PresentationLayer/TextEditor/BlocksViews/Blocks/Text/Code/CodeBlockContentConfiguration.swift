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
    /// Entity for context menu
    weak var contextMenuHolder: TextBlockViewModel?

    /// Block information
    var information: BlockInformation.InformationModel

    init(_ blockViewModel: TextBlockViewModel) {
        self.information = .init(information: blockViewModel.information)
    }
}

extension CodeBlockContentConfiguration: UIContentConfiguration {

    func makeContentView() -> UIView & UIContentView {
        let view: CodeBlockContentView = .init(configuration: self)
        self.contextMenuHolder?.addContextMenuIfNeeded(view)
        return view
    }

    func updated(for state: UIConfigurationState) -> CodeBlockContentConfiguration {
        return self
    }
}

extension CodeBlockContentConfiguration: Hashable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.information == rhs.information
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.information)
    }
}
