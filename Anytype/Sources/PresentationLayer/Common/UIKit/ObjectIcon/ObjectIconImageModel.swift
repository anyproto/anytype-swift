import UIKit

struct ObjectIconImageModel {
    let iconImage: ObjectIconImage
    let usecase: ObjectIconImageUsecase
    
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
