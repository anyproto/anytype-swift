import Foundation
import UIKit
import Kingfisher

// KEEP IN SYNC WITH ObjectIconImageView

final class ObjectIconAttachementLoader {
    
    private let painter: ObjectIconImagePainterProtocol = ObjectIconImagePainter.shared
    weak var attachement: NSTextAttachment?
    
    init() { }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - ConfigurableView

extension ObjectIconAttachementLoader: ConfigurableView {
    func configure(model: ObjectIconImageModel) {
        guard let attachement = attachement else {
            return
        }
        
        switch model.iconImage {
        case .icon(let objectIconType):
            handleObjectIconType(objectIconType, model: model)
        case .todo(let isChecked):
            attachement.image = model.imageGuideline.flatMap {
                painter.todoImage(
                    isChecked: isChecked,
                    imageGuideline: $0
                )
            }
        case .placeholder(let character):
            attachement.image = stringIconImage(
                model: model,

                string: character.flatMap { String($0) } ?? "",
                textColor: UIColor.textTertiary,
                backgroundColor: UIColor.grayscale10
            )
        case .staticImage(let name):
            attachement.image = model.imageGuideline.flatMap {
                painter.staticImage(name: name, imageGuideline: $0)
            }
        }
    }
    
    private func handleObjectIconType(_ type: ObjectIconType, model: Model) {
        guard let attachement = attachement else {
            return
        }
        
        switch type {
        case .basic(let id):
            downloadImage(imageId: id, model: model)
        case .profile(let profile):
            switch profile {
            case .imageId(let id):
                downloadImage(imageId: id, model: model)
            case .character(let character):
                attachement.image = stringIconImage(
                    model: model,
                    string: String(character),
                    textColor: UIColor.backgroundPrimary,
                    backgroundColor: UIColor.dividerSecondary
                )
            }
        case .emoji(let iconEmoji):
            attachement.image = stringIconImage(
                model: model,
                string: iconEmoji.value,
                textColor: UIColor.backgroundPrimary,
                backgroundColor: model.usecase.backgroundColor
            )
        }
    }
    
    private func downloadImage(imageId: String, model: Model) {
        guard let attachement = attachement else {
            return
        }
        
        guard let imageGuideline = model.imageGuideline else {
            attachement.image = nil
            return
        }
        
        attachement.image = ImageBuilder(imageGuideline).build()
        
        let processor = KFProcessorBuilder(
            scalingType: .resizing(.aspectFill),
            targetSize: imageGuideline.size,
            cornerRadius: .point(imageGuideline.cornersGuideline.radius)
        ).processor
        
        guard let url = ImageID(id: imageId, width: imageGuideline.size.width.asImageWidth).resolvedUrl else {
            return
        }
        
        KingfisherManager.shared.retrieveImage(
            with: url,
            options: [.processor(processor)]
        ) { [weak self] result in
            guard case let .success(result) = result else { return }

            self?.attachement?.image = result.image
        }
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
