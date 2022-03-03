//
//  AudioBlockPlayerDelegate.swift
//  Anytype
//
//  Created by Denis Batvinkin on 06.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation


// MARK: - AudioPlayerViewDelegate

extension AudioBlockViewModel: AudioPlayerViewDelegate {

    var currentTime: Double {
        currentTimeInSeconds
    }

    var duration: Double {
        playerItem?.asset.duration.seconds ?? 0
    }

    var isPlaying: Bool {
        audioPlayer.isPlaying(audioId: info.id)
    }

    func playButtonDidPress(sliderValue: Double) {
        if audioPlayer.isPlaying(audioId: info.id) {
            audioPlayer.pause(audioId: info.id)
            audioPlayerView?.pause()
        } else {
            audioPlayer.play(
                audioId: info.id,
                name: fileData.metadata.name,
                playerItem: playerItem,
                seekTime: sliderValue,
                delegate: self
            )
            audioPlayerView?.play()
        }
    }

    func progressSliederChanged(value: Double, completion: @escaping () -> Void) {
        currentTimeInSeconds = value
        audioPlayer.setTrackTime(audioId: info.id, value: value) {
            completion()
        }
    }
}

// MARK: - AnytypeAudioPlayerDelegate

extension AudioBlockViewModel: AnytypeAudioPlayerDelegate {

    func playerReadyToPlay(duration: Double) {}

    func playerReadyToResumeAfterInterruption() {
        audioPlayerView?.play()
    }

    func playerInterrupted() {
        audioPlayerView?.pause()
    }

    func playerItemDidPlayToEndTime() {
        audioPlayerView?.trackTimeChanged(0)
        audioPlayerView?.pause()
    }

    func trackTimeDidChange(timeInSeconds: Double) {
        currentTimeInSeconds = timeInSeconds
        audioPlayerView?.trackTimeChanged(timeInSeconds)
    }

    func stopPlaying() {
        audioPlayerView?.pause()
    }
}

