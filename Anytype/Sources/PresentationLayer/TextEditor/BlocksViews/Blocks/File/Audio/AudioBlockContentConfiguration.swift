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
    let trackId: String
    weak var audioPlayerViewDelegate: AudioPlayerViewDelegate?

    static func == (lhs: AudioBlockContentConfiguration, rhs: AudioBlockContentConfiguration) -> Bool {
        lhs.trackId == rhs.trackId && lhs.audioPlayerViewDelegate === rhs.audioPlayerViewDelegate
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(trackId)
        hasher.combine(audioPlayerViewDelegate?.hashable)
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
