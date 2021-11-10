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
    var currentConfigurationState: UICellConfigurationState?
    weak var audioPlayerViewDelegate: AudioPlayerViewDelegate?

    static func == (lhs: AudioBlockContentConfiguration, rhs: AudioBlockContentConfiguration) -> Bool {
        lhs.trackId == rhs.trackId &&
        lhs.currentConfigurationState == rhs.currentConfigurationState
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(trackId)
        hasher.combine(currentConfigurationState)
    }
}

extension AudioBlockContentConfiguration: AnytypeBlockContentConfigurationProtocol {

    func makeContentView() -> UIView & UIContentView {
        return AudioBlockContentView(configuration: self)
    }
}
