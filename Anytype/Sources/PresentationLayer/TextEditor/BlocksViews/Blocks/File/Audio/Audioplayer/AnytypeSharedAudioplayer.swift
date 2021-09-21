//
//  AnytypeSharedAudioplayer.swift
//  Anytype
//
//  Created by Denis Batvinkin on 19.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import AVFoundation


final class AnytypeSharedAudioplayer {
    static let sharedInstance = AnytypeSharedAudioplayer()

    private var currentAudioItem: AVPlayerItem?
    private let anytypeAudioplayer: AnytypeAudioPlayer

    // MARK: - Lifecycle

    private init() {
        self.anytypeAudioplayer = AnytypeAudioPlayer()
    }

    // MARK: - AnytypeAudioPlayerProtocol

    func pause(playerItem: AVPlayerItem) {
        guard currentAudioItem == playerItem else {
            return
        }
        anytypeAudioplayer.pause()
    }

    func setTrackTime(playerItem: AVPlayerItem, value: Double, completion: @escaping () -> Void) {
        guard currentAudioItem == playerItem else {
            completion()
            return
        }
        anytypeAudioplayer.setTrackTime(value: value, completion: completion)
    }

    func play(playerItem: AVPlayerItem, seekTime: Double, delegate: AnytypeAudioPlayerDelegate) {
        if currentAudioItem != playerItem {
            // pause current audio item
            anytypeAudioplayer.pause()

            // set new audio item
            anytypeAudioplayer.setAudio(playerItem: playerItem, delegate: delegate)
            currentAudioItem = anytypeAudioplayer.audioPlayer.currentItem
        }
        anytypeAudioplayer.setTrackTime(value: seekTime, completion: {})
        anytypeAudioplayer.play()
    }
}
