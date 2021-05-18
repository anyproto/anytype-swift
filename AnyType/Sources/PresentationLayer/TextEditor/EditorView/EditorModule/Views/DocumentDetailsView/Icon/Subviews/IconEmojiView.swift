//
//  IconEmojiView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 12.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit

final class IconEmojiView: UIView {
    
    // MARK: - Private properties
    
    private let emojiLabel: UILabel = UILabel()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUpView()
    }
    
}

// MARK: - ConfigurableView

extension IconEmojiView: ConfigurableView {
    
    func configure(model: IconEmoji) {
        emojiLabel.text = model.value
    }
    
}

// MARK: - Private extension

private extension IconEmojiView {
    
    func setUpView() {
        backgroundColor = .grayscale10
        clipsToBounds = true
        
        configureEmojiLabel()
        
        setUpLayout()
    }
    
    func configureEmojiLabel() {
        emojiLabel.backgroundColor = .grayscale10
        emojiLabel.font = .systemFont(ofSize: 64)
        emojiLabel.textAlignment = .center
        emojiLabel.adjustsFontSizeToFitWidth = true
        emojiLabel.isUserInteractionEnabled = false
    }
    
    func setUpLayout() {
        addSubview(emojiLabel)
        emojiLabel.pinAllEdges(to: self)
    }
    
}
