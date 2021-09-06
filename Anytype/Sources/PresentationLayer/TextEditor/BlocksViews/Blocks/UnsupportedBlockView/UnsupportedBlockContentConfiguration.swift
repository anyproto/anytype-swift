//
//  UnsupportedBlockContentConfiguration.swift
//  Anytype
//
//  Created by Denis Batvinkin on 06.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

struct UnsupportedBlockContentConfiguration {
    let text: String
}

extension UnsupportedBlockContentConfiguration: UIContentConfiguration {

    func makeContentView() -> UIView & UIContentView {
        return UnsupportedBlockView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> UnsupportedBlockContentConfiguration {
        return self
    }
}

extension UnsupportedBlockContentConfiguration: Hashable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.text == rhs.text
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
}
