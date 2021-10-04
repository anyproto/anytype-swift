//
//  AudioBlockContentConfiguration.swift
//  Anytype
//
//  Created by Denis Batvinkin on 14.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import BlocksModels
import UIKit
import AVFoundation


struct AudioBlockContentConfiguration: Hashable {
    let file: BlockFile
    let playerItem: AVPlayerItem
    let duration: Double

    static func == (lhs: AudioBlockContentConfiguration, rhs: AudioBlockContentConfiguration) -> Bool {
        lhs.file == rhs.file
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
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
