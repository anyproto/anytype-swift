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
    /// Action for checked button
    let checkedAction: (Bool) -> Void
    
    /// Entity for context menu
    weak var contextMenuHolder: TextBlockViewModel?
    
    /// Block information
    var information: Block.Information.InformationModel
    
    init(_ block: BlockActiveRecordModelProtocol, checkedAction: @escaping(Bool) -> Void) {
        self.information = .init(information: block.blockModel.information)
        self.checkedAction = checkedAction
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
        lhs.information == rhs.information
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.information)
    }
}
