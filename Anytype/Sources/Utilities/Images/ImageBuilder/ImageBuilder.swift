import Foundation
import UIKit


final class ImageBuilder {
        
    private let imageStorage: some ImageStorageProtocol = ImageStorage.shared
    
    private var imageGuideline: ImageGuideline
    private var imageColor = UIColor.Shape.tertiary
    
    private var text: String?
    private var font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    private var textColor = UIColor.Background.primary
    
    init(_ imageGuideline: ImageGuideline) {
        self.imageGuideline = imageGuideline
    }
    
}

extension ImageBuilder: ImageBuilderProtocol {
    
    @discardableResult
    func setImageColor(_ imageColor: UIColor) -> any ImageBuilderProtocol {
        self.imageColor = imageColor
        return self
    }
    
    @discardableResult
    func setText(_ text: String) -> any ImageBuilderProtocol {
        self.text = text
        return self
    }
    
    @discardableResult
    func setTextColor(_ textColor: UIColor) -> any ImageBuilderProtocol {
        self.textColor = textColor
        return self
    }
    
    @discardableResult
    func setFont(_ font: UIFont) -> any ImageBuilderProtocol {
        self.font = font
        return self
    }
    
    @MainActor
    func build() -> UIImage {
        var key = """
        \(ImageBuilder.self).
        \(imageGuideline.identifier).
        \(imageColor.hexString).
        """
        if let text = text {
            key.append(text)
            key.append(textColor.hexString)
            key.append("\(font)")
        }
        
        if let cachedImage = imageStorage.image(forKey: key) {
            return cachedImage
        }
        
        let image = UIImage.generateDynamicImage {
            
            let isOpaque = imageGuideline.cornersGuideline?.isOpaque ?? false
            let format = UIGraphicsImageRendererFormat.preferred()
            format.opaque = isOpaque
            
            return UIGraphicsImageRenderer(
                size: imageGuideline.size,
                format: format
            )
                .image { ctx in
                    ctx.cgContext.setFillColor(imageColor.cgColor)
                    ctx.fill(ctx.format.bounds)
                    
                    text.flatMap {
                       draw(text: $0)
                    }
                    
                }
                .rounded(
                    radius: imageGuideline.cornerRadius,
                    opaque: isOpaque,
                    backgroundColor: imageGuideline.cornersGuideline?.backgroundColor?.cgColor
            )
        }
        
        imageStorage.saveImage(image, forKey: key)

        return image
    }
    
    private func draw(text: String) {
        let textSize = NSString(string: text)
            .size(withAttributes: [.font: self.font])
        
        let textRect = CGRect(
            x: 0,
            y: (imageGuideline.size.height - textSize.height) / 2,
            width: imageGuideline.size.width,
            height: textSize.height
        )
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        text.draw(
            with: textRect,
            options: [
                .usesLineFragmentOrigin,
                .usesFontLeading
            ],
            attributes: [
                .foregroundColor: self.textColor,
                .font: self.font,
                .paragraphStyle: paragraphStyle
            ],
            context: nil
        )
    }
    
}

private extension ImageCornersGuideline {
    
    var isOpaque: Bool {
        guard let backgroundColor = backgroundColor else { return false }
        
        return !backgroundColor.isTransparent
    }
    
}
