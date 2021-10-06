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

    private let anytypeAudioplayer: AnytypeAudioPlayer
    private(set) var currentAudioId: String = ""

    var isPlaying: Bool {
        anytypeAudioplayer.isPlaying
    }

    var duration: Double? {
        anytypeAudioplayer.duration
    }

    var currentTime: Double {
        anytypeAudioplayer.currentTime
    }

    // MARK: - Lifecycle

    private init() {
        self.anytypeAudioplayer = AnytypeAudioPlayer()
    }

    // MARK: - Public methods

    func pause(audioId: String) {
        guard currentAudioId == audioId else {
            return
        }
        anytypeAudioplayer.pause()
    }

    func setTrackTime(audioId: String, value: Double, completion: @escaping () -> Void) {
        guard currentAudioId == audioId else {
            completion()
            return
        }
        anytypeAudioplayer.setTrackTime(value: value, completion: completion)
    }

    func play(audioId: String, playerItem: AVPlayerItem, seekTime: Double, delegate: AnytypeAudioPlayerDelegate) {
        if currentAudioId != audioId {
            // pause current audio item
            anytypeAudioplayer.pause()

            // set new audio item
            anytypeAudioplayer.setAudio(playerItem: playerItem, delegate: delegate)
            currentAudioId = audioId
        }
        anytypeAudioplayer.setTrackTime(value: seekTime, completion: {})
        anytypeAudioplayer.play()
    }

    func updateDelegate(audioId: String, delegate: AnytypeAudioPlayerDelegate) {
        guard currentAudioId == audioId else { return }

        anytypeAudioplayer.delegate = delegate
    }
}
