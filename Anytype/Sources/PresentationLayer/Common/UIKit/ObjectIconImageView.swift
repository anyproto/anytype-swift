//
//  ObjectIconImageView.swift
//  ObjectIconImageView
//
//  Created by Konstantin Mordan on 26.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

final class ObjectIconImageView: UIView {
    
    private let painter: ObjectIconImagePainterProtocol = ObjectIconImagePainter.shared
    private let imageView = UIImageView()
    
    init() {
        super.init(frame: .zero)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - ConfigurableView

extension ObjectIconImageView: ConfigurableView {
    
    struct Model {
        let iconImage: ObjectIconImage
        let usecase: ObjectIconImageUsecase
    }
    
    func configure(model: Model) {
        imageView.kf.cancelDownloadTask()
        
        switch model.iconImage {
        case .icon(let objectIconType):
            handleObjectIconType(objectIconType, model: model)
        case .todo(let isChecked):
            imageView.image = model.imageGuideline.flatMap {
                painter.todoImage(
                    isChecked: isChecked,
                    imageGuideline: $0
                )
            }
        case .placeholder(let character):
            imageView.image = stringIconImage(
                model: model,
                string: character.flatMap { String($0) } ?? "",
                textColor: UIColor.textTertiary,
                backgroundColor: UIColor.grayscale10
            )
        }
    }
    
    func handleObjectIconType(_ type: ObjectIconType, model: Model) {
        switch type {
        case .basic(let id):
            downloadImage(imageId: id, model: model)
        case .profile(let profile):
            switch profile {
            case .imageId(let id):
                downloadImage(imageId: id, model: model)
            case .character(let character):
                imageView.image = stringIconImage(
                    model: model,
                    string: String(character),
                    textColor: UIColor.grayscaleWhite,
                    backgroundColor: UIColor.dividerSecondary
                )
            }
        case .emoji(let iconEmoji):
            imageView.image = stringIconImage(
                model: model,
                string: iconEmoji.value,
                textColor: UIColor.grayscaleWhite,
                backgroundColor: model.usecase == .openedObjectNavigationBar ? .clear : UIColor.grayscale10
            )
        }
    }
    
    private func downloadImage(imageId: String, model: Model) {
        guard let imageGuideline = model.imageGuideline else {
            imageView.image = nil
            return
        }
        
        let placeholder = ImageBuilder(imageGuideline).build()
        
        let processor = KFProcessorBuilder(
            scalingType: .resizing(.aspectFill),
            targetSize: imageGuideline.size,
            cornerRadius: .point(imageGuideline.cornersGuideline.radius)
        ).processor
        
        imageView.kf.setImage(
            with: ImageID(id: imageId, width: imageGuideline.size.width.asImageWidth).resolvedUrl,
            placeholder: placeholder,
            options: [.processor(processor), .transition(.fade(0.2))]
        )
    }
    
    private func stringIconImage(
        model: Model,
        string: String,
        textColor: UIColor,
        backgroundColor: UIColor
    ) -> UIImage? {
        guard let imageGuideline = model.imageGuideline, let font = model.font else { return nil}
        
        return painter.image(
            with: string,
            font: font,
            textColor: textColor,
            imageGuideline: imageGuideline,
            backgroundColor: backgroundColor
        )
    }
    
}

// MARK: - Private extension

private extension ObjectIconImageView {
    
    func setupView() {
        clipsToBounds = true
        imageView.contentMode = .center
        setupLayout()
    }
    
    func setupLayout() {
        addSubview(imageView) {
            $0.pinToSuperview()
        }
    }
    
}

// MARK: - Private `ObjectIconImageView.Model` extension

private extension ObjectIconImageView.Model {
    
    var imageGuideline: ImageGuideline? {
        self.usecase.objectIconImageGuidelineSet.imageGuideline(
            for: self.iconImage
        )
    }
    
    var font: UIFont? {
        self.usecase.objectIconImageFontSet.imageFont(
            for: self.iconImage
        )
    }
    
}
