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
    let information: BlockInformationModelProtocol
    
    /// Does block have children
    let hasChildren: Bool
    
    /// Block view model value
    let blockVM: BlocksViews.New.Text.Base.ViewModel
    
    /// Entity for context menu
    weak var contextMenuHolder: BlocksViews.New.Text.Base.ViewModel?
    
    init?(_ blockViewModel: BlocksViews.New.Text.Base.ViewModel) {
        if case let .text(text) = blockViewModel.getBlock().blockModel.information.content,
           text.contentType == .toggle {
            self.blockVM = blockViewModel
            self.information = blockViewModel.getBlock().blockModel.information
            self.hasChildren = !blockViewModel.getBlock().childrenIds().isEmpty
        } else {
            return nil
        }
    }
}

extension ToggleBlockContentConfiguration: UIContentConfiguration {
    
    func makeContentView() -> UIView & UIContentView {
        let view: ToggleBlockContentView = .init(configuration: self)
        self.contextMenuHolder?.addContextMenuIfNeeded(view)
        return view
    }
    
    func updated(for state: UIConfigurationState) -> ToggleBlockContentConfiguration {
        return self
    }
}

extension ToggleBlockContentConfiguration: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.information.id == rhs.information.id &&
        lhs.information.content == rhs.information.content &&
        lhs.blockVM.getBlock().isToggled == rhs.blockVM.getBlock().isToggled &&
        lhs.hasChildren == rhs.hasChildren
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.information.id)
        hasher.combine(self.information.content)
        hasher.combine(self.blockVM.getBlock().isToggled)
        hasher.combine(self.hasChildren)
    }
}

