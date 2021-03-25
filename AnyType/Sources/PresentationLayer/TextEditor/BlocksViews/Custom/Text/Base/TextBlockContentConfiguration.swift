//
//  TextBlockContentConfiguration.swift
//  AnyType
//
//  Created by Kovalev Alexander on 10.03.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import BlocksModels
import UIKit

/// Content configuration for text blocks
struct TextBlockContentConfiguration {
    
    private let container: TopLevel.AliasesMap.BlockInformationUtilities.AsHashable
    
    /// Block value
    let block: BlockActiveRecordModelProtocol
    
    /// Action for checked button
    let checkedAction: (Bool) -> Void
    
    /// Entity for context menu
    weak var contextMenuHolder: BlocksViews.New.Text.Base.ViewModel?
    
    /// Block information
    var information: BlockInformationModelProtocol {
        self.container.value
    }
    
    init?(_ block: BlockActiveRecordModelProtocol,
          checkedAction: @escaping(Bool) -> Void) {
        if case .text = block.blockModel.information.content {
            self.container = .init(value: block.blockModel.information)
            self.block = block
            self.checkedAction = checkedAction
        } else {
            return nil
        }
    }
}

extension TextBlockContentConfiguration: UIContentConfiguration {
    
    func makeContentView() -> UIView & UIContentView {
        let view: TextBlockContentView = .init(configuration: self)
        self.contextMenuHolder?.addContextMenuIfNeeded(view)
        return view
    }
    
    func updated(for state: UIConfigurationState) -> TextBlockContentConfiguration {
        return self
    }
}

extension TextBlockContentConfiguration: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.container == rhs.container
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.container)
    }
}
