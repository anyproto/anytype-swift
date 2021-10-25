//
//  FeaturedRelationsBlockViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 25.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit
import BlocksModels

// TODO: Check if block updates when featuredRelations is changed
struct FeaturedRelationsBlockViewModel: BlockViewModelProtocol {
    var upperBlock: BlockModelProtocol?

    let indentationLevel: Int = 0
    let information: BlockInformation
    let type: String
    
    var hashable: AnyHashable {
        [
            indentationLevel,
            information,
            type
        ] as [AnyHashable]
    }
    
    init(information: BlockInformation, type: String) {
        self.information = information
        self.type = type
    }
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        UnsupportedBlockContentConfiguration(text: type)
    }
    
    func didSelectRowInTableView() {}
    
    func makeContextualMenu() -> [ContextualMenu] {
        []
    }
    
    func handle(action: ContextualMenu) {}
    
}
