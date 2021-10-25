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

struct FeaturedRelationsBlockViewModel: BlockViewModelProtocol {
    var upperBlock: BlockModelProtocol?

    let indentationLevel: Int = 0
    let information: BlockInformation
    
    var hashable: AnyHashable {
        [
            indentationLevel,
            information
        ] as [AnyHashable]
    }
    
    init(information: BlockInformation) {
        self.information = information
    }
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        UnsupportedBlockContentConfiguration(text: "FeaturedRelationsBlock".localized)
    }
    
    func didSelectRowInTableView() {}
    
    func makeContextualMenu() -> [ContextualMenu] {
        []
    }
    
    func handle(action: ContextualMenu) {}
    
}
