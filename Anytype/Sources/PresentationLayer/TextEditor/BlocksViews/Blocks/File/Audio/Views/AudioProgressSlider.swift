//
//  AudioProgressSlider.swift
//  Anytype
//
//  Created by Denis Batvinkin on 19.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit


final class AudioProgressSlider: UISlider {
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }

    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        let circleImage = UIImage(systemName: "circle.fill")?.scaled(to: AudioProgressSlider.thumbSize)
            .withTintColor(.Control.primary, renderingMode: .alwaysOriginal)
        minimumTrackTintColor = .Control.primary
        setThumbImage(circleImage, for: .normal)
        setThumbImage(circleImage, for: .highlighted)
    }
}

private extension AudioProgressSlider {
    static let thumbSize: CGSize = .init(width: 12, height: 12)
}
