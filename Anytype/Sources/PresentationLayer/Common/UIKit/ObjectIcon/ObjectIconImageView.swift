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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        currentModel.map(configure(model:))
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - ConfigurableView

extension ObjectIconImageView: ConfigurableView {    
    func configure(model: ObjectIconImageModel) {
        imageView.kf.cancelDownloadTask()
        
        switch model.iconImage {
        case .icon(let objectIconType):
            handleObjectIconType(objectIconType, model: model)
        case .todo(let isChecked):
            imageView.image = model.imageGuideline.flatMap {
                painter.todoImage(isChecked: isChecked, imageGuideline: $0)
            }
        case .placeholder(let character):
            imageView.image = stringIconImage(
                model: model,
                string: character.flatMap { String($0).uppercased() } ?? "",
                textColor: UIColor.textTertiary,
                backgroundColor: model.usecase.placeholderBackgroundColor
            )
        case .staticImage(let name):
            imageView.image = model.imageGuideline.flatMap {
                painter.staticImage(name: name, imageGuideline: $0)
            }
        case .image(let image):
            imageView.image = image
        }

        currentModel = model
    }
    
    private func handleObjectIconType(_ type: ObjectIconType, model: Model) {
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
                    string: String(character).uppercased(),
                    textColor: UIColor.textWhite,
                    backgroundColor: model.usecase.profileBackgroundColor
                )
            }
        case .emoji(let iconEmoji):
            imageView.image = stringIconImage(
                model: model,
                string: iconEmoji.value,
                textColor: UIColor.backgroundPrimary,
                backgroundColor: model.usecase.emojiBackgroundColor
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
            cornerRadius: imageGuideline.cornersGuideline.radius
        ).processor
        
        imageView.kf.setImage(
            with: ImageMetadata(id: imageId, width: imageGuideline.size.width.asImageWidth).contentUrl,
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
