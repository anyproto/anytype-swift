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

extension ObjectIconAttachementLoader {
    func configure(model: ObjectIconImageModel, processor: ImageProcessor) {        
        switch model.iconImage {
        case .icon(let objectIconType):
            handleObjectIconType(objectIconType, model: model, customProcessor: processor)
        case .todo(let isChecked):
            let image = model.imageGuideline.flatMap {
                painter.todoImage(
                    isChecked: isChecked,
                    imageGuideline: $0
                )
            }
            setImage(image: image, processor: processor)
            
        case .placeholder(let character):
            let image = stringIconImage(
                model: model,
                string: character.flatMap { String($0).uppercased() } ?? "",
                textColor: UIColor.textTertiary,
                backgroundColor: model.usecase.placeholderBackgroundColor
            )
            setImage(image: image, processor: processor)
        case .staticImage(let name):
            let image = model.imageGuideline.flatMap {
                painter.staticImage(name: name, imageGuideline: $0)
            }
            setImage(image: image, processor: processor)
        case .image(let image):
            setImage(image: image, processor: processor)
        }
    }
    
    private func handleObjectIconType(
        _ type: ObjectIconType,
        model: ObjectIconImageModel,
        customProcessor: ImageProcessor
    ) {
        switch type {
        case .basic(let id):
            downloadImage(imageId: id, model: model, customProcessor: customProcessor)
        case .profile(let profile):
            switch profile {
            case .imageId(let id):
                downloadImage(imageId: id, model: model, customProcessor: customProcessor)
            case .character(let character):
                let image = stringIconImage(
                    model: model,
                    string: String(character).uppercased(),
                    textColor: UIColor.textWhite,
                    backgroundColor: model.usecase.profileBackgroundColor
                )
                setImage(image: image, processor: customProcessor)
            }
        case .emoji(let iconEmoji):
            let image = stringIconImage(
                model: model,
                string: iconEmoji.value,
                textColor: UIColor.backgroundPrimary,
                backgroundColor: model.usecase.emojiBackgroundColor
            )
            setImage(image: image, processor: customProcessor)
        }
    }
    
    private func downloadImage(
        imageId: String,
        model: ObjectIconImageModel,
        customProcessor: ImageProcessor
    ) {
        guard let attachement = attachement else {
            return
        }
        
        guard let imageGuideline = model.imageGuideline else {
            attachement.image = nil
            return
        }
        
        setImage(image: ImageBuilder(imageGuideline).build(), processor: customProcessor)
        
        let processor = KFProcessorBuilder(
            scalingType: .resizing(.aspectFill),
            targetSize: imageGuideline.size,
            cornerRadius: .point(imageGuideline.cornersGuideline.radius)
        ).processor |> customProcessor
        
        guard let url = ImageMetadata(id: imageId, width: imageGuideline.size.width.asImageWidth).contentUrl else {
            return
        }
        
        AnytypeImageDownloader.retrieveImage(with: url, options: [.processor(processor)]) { [weak self] image in
            self?.attachement?.image = image
        }
    }
    
    private func stringIconImage(
        model: ObjectIconImageModel,
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
    
    private func setImage(image: UIImage?, processor: ImageProcessor) {
        guard let image = image else { return }
        attachement?.image = processor.process(item: .image(image), options: .init(nil))
    }
    
}
