//
//  TextBlockContentConfiguration.swift
//  AnyType
//
//  Created by Kovalev Alexander on 10.03.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import BlocksModels
import UIKit
import Combine


/// Content configuration for text blocks
struct TextBlockContentConfiguration {
    
    let marksPaneActionSubject: PassthroughSubject<MarksPane.Main.Action, Never>
    let toolbarActionSubject: PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
    let viewModel: TextBlockViewModel
    let information: BlockInformation
    
    private(set) weak var textViewDelegate: TextViewDelegate?
    private(set) var isSelected: Bool = false

    /// text block view model

    /// Block information
    
    init(
         textViewDelegate: TextViewDelegate?,
         viewModel: TextBlockViewModel,
         marksPaneActionSubject: PassthroughSubject<MarksPane.Main.Action, Never>,
         toolbarActionSubject: PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
    ) {
        self.marksPaneActionSubject = marksPaneActionSubject
        self.toolbarActionSubject = toolbarActionSubject
        self.textViewDelegate = textViewDelegate
        self.information = viewModel.information
        self.viewModel = viewModel
    }
}

extension TextBlockContentConfiguration: UIContentConfiguration {
    
    func makeContentView() -> UIView & UIContentView {
        let view = TextBlockContentView(configuration: self)
        viewModel.addContextMenuIfNeeded(view)
        return view
    }
    
    func updated(for state: UIConfigurationState) -> TextBlockContentConfiguration {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfig = self

        updatedConfig.isSelected = state.isSelected
        return updatedConfig
    }
}

extension TextBlockContentConfiguration: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.information == rhs.information && lhs.isSelected == rhs.isSelected
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(information)
        hasher.combine(isSelected)
    }
    
}
