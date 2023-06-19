
import Foundation
import UIKit

protocol ObjectIconImagePainterProtocol {
    
    func todoImage(isChecked: Bool, imageGuideline: ImageGuideline, tintColor: UIColor) -> UIImage
    func staticImage(imageAsset: ImageAsset, imageGuideline: ImageGuideline, tintColor: UIColor?) -> UIImage
    func image(
        with string: String,
        font: UIFont,
        textColor: UIColor,
        imageGuideline: ImageGuideline,
        backgroundColor: UIColor
    ) -> UIImage
    
    func image(
        with string: String,
        font: UIFont,
        textColor: UIColor,
        imageGuideline: ImageGuideline,
        backgroundColor: UIColor
    ) async -> UIImage
    
    func gradientImage(gradientId: GradientId, imageGuideline: ImageGuideline) async -> UIImage
    
    func spaceImage(
        space: ObjectIconType.Space,
        imageGuideline: ImageGuideline,
        font: UIFont,
        backgroundColor: UIColor
    ) async -> UIImage
}


extension ObjectIconImagePainterProtocol {
    
    func gradientImage(gradientId: GradientId, model: ObjectIconImageModel) async -> UIImage? {
        guard let imageGuideline = model.imageGuideline else { return nil }
        return await gradientImage(gradientId: gradientId, imageGuideline: imageGuideline)
    }
    
    func spaceImage(space: ObjectIconType.Space, model: ObjectIconImageModel ) async -> UIImage? {
        guard let imageGuideline = model.imageGuideline,
              let font = model.font else { return nil }
        
        return await spaceImage(space: space, imageGuideline: imageGuideline, font: font, backgroundColor: model.usecase.spaceBackgroundColor)
    }
}
