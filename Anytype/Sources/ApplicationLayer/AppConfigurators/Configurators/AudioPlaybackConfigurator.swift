//
//  AudioPlaybackConfigurator.swift
//  Anytype
//
//  Created by Denis Batvinkin on 17.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import AVFoundation


final class AudioPlaybackConfigurator: AppConfiguratorProtocol {

    func configure() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)

            if !AVAudioSession.sharedInstance().isOtherAudioPlaying {
                try AVAudioSession.sharedInstance().setActive(true)
            }

            //!! IMPORTANT !!
            /*
             If you're using 3rd party libraries to play sound or generate sound you should
             set sample rate manually here.
             Otherwise you wont be able to hear any sound when you lock screen
             */
            //try AVAudioSession.sharedInstance().setPreferredSampleRate(4096)
        } catch { }
    }
}
