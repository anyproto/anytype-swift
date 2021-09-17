//
//  AudioBlockContentConfiguration.swift
//  Anytype
//
//  Created by Denis Batvinkin on 14.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import BlocksModels
import UIKit

struct AudioBlockContentConfiguration: Hashable {

    let file: BlockFile

    init(fileData: BlockFile) {
        self.file = fileData
    }
}

extension AudioBlockContentConfiguration: UIContentConfiguration {

    func makeContentView() -> UIView & UIContentView {
        return AudioBlockContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> AudioBlockContentConfiguration {
        self
    }
}
