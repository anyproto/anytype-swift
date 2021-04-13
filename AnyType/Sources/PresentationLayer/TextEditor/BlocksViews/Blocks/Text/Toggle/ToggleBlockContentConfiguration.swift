//
//  ToggleBlockContentConfiguration.swift
//  AnyType
//
//  Created by Kovalev Alexander on 24.03.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import BlocksModels
import UIKit

/// Content configuration for text blocks
struct ToggleBlockContentConfiguration {
    
    /// Content value
    /// Because block is a reference type, it will always contains actual information
    /// We need this property to compare old information with new to detect changes
    let information: BlockInformation.InformationModel
    
    /// Does block have children
    let hasChildren: Bool
    
    /// Is block toggled
    let isToggled: Bool
    
    /// Block view model value
    let blockViewModel: TextBlockViewModel
    
    init(_ blockViewModel: TextBlockViewModel) {
        self.blockViewModel = blockViewModel
        self.information = blockViewModel.getBlock().blockModel.information
        self.hasChildren = !blockViewModel.getBlock().childrenIds().isEmpty
        self.isToggled = blockViewModel.getBlock().isToggled
    }
}

extension ToggleBlockContentConfiguration: UIContentConfiguration {
    
    func makeContentView() -> UIView & UIContentView {
        let view: ToggleBlockContentView = .init(configuration: self)
        self.blockViewModel.addContextMenuIfNeeded(view)
        return view
    }
    
    func updated(for state: UIConfigurationState) -> ToggleBlockContentConfiguration {
        return self
    }
}

extension ToggleBlockContentConfiguration: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.information == rhs.information &&
        lhs.isToggled == rhs.isToggled &&
        lhs.hasChildren == rhs.hasChildren
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.information.id)
        hasher.combine(self.information.content)
        hasher.combine(self.isToggled)
        hasher.combine(self.hasChildren)
    }
}

