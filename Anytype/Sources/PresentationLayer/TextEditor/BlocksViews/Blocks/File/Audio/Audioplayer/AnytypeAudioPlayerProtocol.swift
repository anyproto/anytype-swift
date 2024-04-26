//
//  AnytypeAudioPlayerProtocol.swift
//  Anytype
//
//  Created by Denis Batvinkin on 19.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import AVFoundation


protocol AnytypeAudioPlayerDelegate: AnyObject {
    func playerReadyToPlay(duration: Double)
    func playerReadyToResumeAfterInterruption()
    func playerInterrupted()
    func playerItemDidPlayToEndTime()
    func trackTimeDidChange(timeInSeconds: Double)
    func stopPlaying()
}


@MainActor
protocol AnytypeAudioPlayerProtocol {
    func setAudio(playerItem: AVPlayerItem?, name: String, delegate: AnytypeAudioPlayerDelegate)
    func play()
    func pause()
    func setTrackTime(value: Double, completion: @escaping () -> Void)
}
