import Foundation
import UIKit

final class ObjectIconImagePainter {
    
    static let shared = ObjectIconImagePainter()
    
    private let imageStorage: ImageStorageProtocol = ImageStorage.shared
    private let gradientStorage: IconGradientStorageProtocol = IconGradientStorage()
       
}

extension ObjectIconImagePainter: ObjectIconImagePainterProtocol {
    
    func todoImage(isChecked: Bool, imageGuideline: ImageGuideline, tintColor: UIColor) -> UIImage {
        let hash = "todo.\(isChecked).\(imageGuideline.identifier)"
        let image = UIImage(asset: isChecked ? .todoCheckmark : .todoCheckbox) ?? UIImage()
        return draw(hash: hash, image: image, imageGuideline: imageGuideline, tintColor: tintColor)
    }
    
    func staticImage(imageAsset: ImageAsset, imageGuideline: ImageGuideline, tintColor: UIColor?) -> UIImage {
        let hash = "staticImage.\(imageAsset.identifier).\(imageGuideline.identifier)"
        let image = UIImage(asset: imageAsset) ?? UIImage()
        return draw(hash: hash, image: image, imageGuideline: imageGuideline, tintColor: tintColor)
    }
    
    private func draw(hash: String, image: UIImage, imageGuideline: ImageGuideline, tintColor: UIColor? = nil) -> UIImage {
        if let image = imageStorage.image(forKey: hash) {
            return image
        }

        let modifiedImage = UIImage.generateDynamicImage {
            image
                .applyTint(color: tintColor)
                .scaled(to: imageGuideline.size)
                .rounded(
                    radius: imageGuideline.cornerRadius,
                    backgroundColor: imageGuideline.cornersGuideline?.backgroundColor?.cgColor
                )
        }
        imageStorage.saveImage(modifiedImage, forKey: hash)
        
        return modifiedImage
    }
    
    func image(
        with string: String,
        font: UIFont,
        textColor: UIColor,
        imageGuideline: ImageGuideline,
        backgroundColor: UIColor
    ) -> UIImage {
        ImageBuilder(imageGuideline)
            .setText(string)
            .setFont(font)
            .setTextColor(textColor)
            .setImageColor(backgroundColor)
            .build()
    }
    
    func image(
        with string: String,
        font: UIFont,
        textColor: UIColor,
        imageGuideline: ImageGuideline,
        backgroundColor: UIColor
    ) async -> UIImage {
        return await withCheckedContinuation { continuation in
            let image = ImageBuilder(imageGuideline)
                .setText(string)
                .setFont(font)
                .setTextColor(textColor)
                .setImageColor(backgroundColor)
                .build()
            continuation.resume(with: .success(image))
        }
    }
    
    func gradientImage(gradientId: GradientId, imageGuideline: ImageGuideline) async -> UIImage {
        let hash = "gradient.\(gradientId.rawValue).\(imageGuideline.identifier)"
        if let image = imageStorage.image(forKey: hash) {
            return image
        }
        
        let gradient = gradientStorage.gradient(for: gradientId.rawValue)
        
        let image: UIImage = await withCheckedContinuation { continuation in
            let image = UIImage.circleGradient(
                size: imageGuideline.size,
                centerColor: gradient.centerColor,
                roundColor: gradient.roundColor,
                centerLocation: gradient.centerLocation,
                roundLocation: gradient.roundLocation,
                backgroundColor: imageGuideline.cornersGuideline?.backgroundColor,
                cornerRadius: imageGuideline.cornerRadius
            )
            continuation.resume(with: .success(image))
        }
        
        imageStorage.saveImage(image, forKey: hash)
        return image
    }
    
    func spaceImage(
        space: ObjectIconType.Space,
        imageGuideline: ImageGuideline,
        font: UIFont,
        backgroundColor: UIColor
    ) async -> UIImage {
        switch space {
        case let .character(ch):
            return await image(with: ch.uppercased(), font: font, textColor: .Text.white, imageGuideline: imageGuideline, backgroundColor: backgroundColor)
        case let .gradient(gradientId):
            let cornersGuideline = imageGuideline.cornersGuideline.map { ImageCornersGuideline(radius: $0.radius, backgroundColor: .Additional.space) }
            let guideline = ImageGuideline(size: imageGuideline.size, cornersGuideline: cornersGuideline)
            return await gradientImage(gradientId: gradientId, imageGuideline: guideline)
        }
    }
}
