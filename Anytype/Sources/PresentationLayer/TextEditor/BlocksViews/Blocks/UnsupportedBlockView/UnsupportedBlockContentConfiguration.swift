//
//  UnsupportedBlockContentConfiguration.swift
//  Anytype
//
//  Created by Denis Batvinkin on 06.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

struct UnsupportedBlockContentConfiguration: AnytypeBlockContentConfigurationProtocol {
    let text: String
    var currentConfigurationState: UICellConfigurationState?
}

extension UnsupportedBlockContentConfiguration: UIContentConfiguration {

    func makeContentView() -> UIView & UIContentView {
        return UnsupportedBlockView(configuration: self)
    }
}
