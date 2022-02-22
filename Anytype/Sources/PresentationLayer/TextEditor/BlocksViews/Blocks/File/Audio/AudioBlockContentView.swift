//
//  AudioBlockContentView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 14.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Combine
import UIKit
import BlocksModels
import AnytypeCore


final class AudioBlockContentView: UIView, BlockContentView {
    // MARK: - Views
    let audioPlayerView = AudioPlayerView()
    let backgroundView = UIView()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        setupLayout()
    }

    func update(with configuration: AudioBlockContentConfiguration) {
        apply(configuration: configuration)
    }

    private func setup() {
        backgroundColor = .clear
    }

    private func setupLayout() {
        addSubview(backgroundView) {
            $0.pinToSuperview(insets: Layout.blockBackgroundPadding)
        }

        addSubview(audioPlayerView) {
            $0.pinToSuperview(insets: Layout.blockContentPadding)
        }
    }

    private func apply(configuration: AudioBlockContentConfiguration) {
        audioPlayerView.setDelegate(delegate: configuration.audioPlayerViewDelegate)
        audioPlayerView.updateAudioInformation(delegate: configuration.audioPlayerViewDelegate)
        audioPlayerView.trackNameLabel.setText(configuration.file.metadata.name)
    }
}

private extension AudioBlockContentView {
    enum Layout {
        static let blockContentPadding: UIEdgeInsets = .init(top: 10, left: 20, bottom: -10, right: -10)
        static let blockBackgroundPadding: UIEdgeInsets = .init(top: 10, left: 0, bottom: -10, right: 0)
    }
}
