//
//  AudioBlockContentConfiguration.swift
//  Anytype
//
//  Created by Denis Batvinkin on 14.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Services
import UIKit
import AVFoundation


struct AudioBlockContentConfiguration: BlockConfiguration {
    typealias View = AudioBlockContentView

    let file: BlockFile
    let trackId: String
    weak var audioPlayerViewDelegate: AudioPlayerViewDelegate?

    static func == (lhs: AudioBlockContentConfiguration, rhs: AudioBlockContentConfiguration) -> Bool {
        lhs.trackId == rhs.trackId &&
        lhs.audioPlayerViewDelegate === rhs.audioPlayerViewDelegate
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(trackId)
    }
}

extension AudioBlockContentConfiguration {
    var contentInsets: UIEdgeInsets { .init(top: 10, left: 20, bottom: 10, right: 20) }
}
