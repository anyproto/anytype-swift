import Foundation
import UIKit
import Kingfisher

// KEEP IN SYNC WITH ObjectIconAttachementLoader

final class ObjectIconImageView: UIView {
    
    private let painter: ObjectIconImagePainterProtocol = ObjectIconImagePainter.shared
    private var currentModel: ObjectIconImageModel?
    let imageView = UIImageView()
    
    init() {
        super.init(frame: .zero)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            currentModel.map { configure(model: $0) }
        }
    }
    
}

// MARK: - ConfigurableView

extension ObjectIconImageView: ConfigurableView {    
    func configure(model: ObjectIconImageModel) {
        switch model.iconImage {
        case .icon(let objectIconType):
            handleObjectIconType(objectIconType, model: model)
        case .todo(let isChecked):
            let image: UIImage? = model.imageGuideline.flatMap {
                painter.todoImage(isChecked: isChecked, imageGuideline: $0)
            }
            imageView.wrapper.setImage(image)
        case .placeholder(let character):
            let image: UIImage? = stringIconImage(
                model: model,
                string: character.flatMap { String($0).uppercased() } ?? "",
                textColor: UIColor.Text.tertiary,
                backgroundColor: model.usecase.placeholderBackgroundColor
            )
            imageView.wrapper.setImage(image)
        case .imageAsset(let imageAsset):
            let image: UIImage? = model.imageGuideline.flatMap {
                painter.staticImage(imageAsset: imageAsset, imageGuideline: $0)
            } ?? UIImage(asset: imageAsset)
            imageView.wrapper.setImage(image)
        case .image(let image):
            imageView.wrapper.setImage(image)
        }

        currentModel = model
    }
    
    private func handleObjectIconType(_ type: ObjectIconType, model: Model) {
        switch type {
        case .basic(let id), .bookmark(let id):
            downloadImage(imageId: id, model: model)
        case .profile(let profile):
            switch profile {
            case .imageId(let id):
                downloadImage(imageId: id, model: model)
            case .character(let character):
                let image: UIImage? = stringIconImage(
                    model: model,
                    string: String(character).uppercased(),
                    textColor: UIColor.Text.white,
                    backgroundColor: model.usecase.profileBackgroundColor
                )
                imageView.wrapper.setImage(image)
            case .gradient(let gradientId):
                gradientIcon(gradientId: gradientId, model: model)
            }
        case .emoji(let iconEmoji):
            let image: UIImage? = stringIconImage(
                model: model,
                string: iconEmoji.value,
                textColor: UIColor.Background.primary,
                backgroundColor: model.usecase.emojiBackgroundColor
            )
            imageView.wrapper.setImage(image)
        case .space(let space):
            spaceIcon(space: space, model: model)
        }
    }
    
    private func downloadImage(imageId: String, model: Model) {
        guard let imageGuideline = model.imageGuideline else {
            imageView.wrapper.setImage(nil)
            return
        }

        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageGuideline.cornerRadius

        imageView.wrapper
            .imageGuideline(imageGuideline)
            .setImage(id: imageId)
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
    
    private func gradientIcon(gradientId: GradientId, model: Model) {
        Task { @MainActor in
            let image = await painter.gradientImage(gradientId: gradientId, model: model)
            imageView.wrapper.setImage(image)
        }
    }
    
    private func spaceIcon(space: ObjectIconType.Space, model: Model) {
        Task { @MainActor in
            let image = await painter.spaceImage(space: space, model: model)
            imageView.wrapper.setImage(image)
        }
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
