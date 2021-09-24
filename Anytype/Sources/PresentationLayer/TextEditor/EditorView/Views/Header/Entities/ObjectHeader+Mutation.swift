import UIKit

extension ObjectHeader {
    
    func modifiedByLocalEvent(_ event: ObjectHeaderLocalEvent) -> ObjectHeader? {
        switch event {
        case .iconUploading(let uIImage):
            return modifiedByIconUploadingEventWith(image: uIImage)
        case .coverUploading(let uIImage):
            return modifiedByCoverUploadingEventWith(image: uIImage)
        }
    }
    
    private func modifiedByIconUploadingEventWith(image: UIImage) -> ObjectHeader? {
        switch self {
        case .iconOnly(let objectIcon):
            return .iconOnly(modifiedObjectIcon(objectIcon, image))
        case .coverOnly(let objectCover):
            return .iconAndCover(
                icon: modifiedObjectIcon(nil, image),
                cover: objectCover
            )
        case .iconAndCover(let objectIcon, let objectCover):
            return .iconAndCover(
                icon: modifiedObjectIcon(objectIcon, image),
                cover: objectCover
            )
        case .empty:
            return .iconOnly(modifiedObjectIcon(nil, image))
        }
    }
    
    private func modifiedObjectIcon(_ objectIcon: ObjectHeaderIcon?, _ image: UIImage) -> ObjectHeaderIcon {
        return ObjectHeaderIcon(icon: .basicPreview(image), layoutAlignment: .left)
//        guard let objectIcon = objectIcon else {
//            return ObjectHeaderIcon(icon: .basicPreview(image), layoutAlignment: .left)
//        }
        
//        switch objectIcon {
//        case .icon(let documentIconType, let layoutAlignment):
//            switch documentIconType {
//            case .basic:
//                return .preview(.basic(image), layoutAlignment)
//            case .profile:
//                return .preview(.profile(image), layoutAlignment)
//            case .emoji:
//                return .preview(.basic(image), layoutAlignment)
//            }
//        case .preview(let objectIconPreviewType, let layoutAlignment):
//            switch objectIconPreviewType {
//            case .basic:
//                return .preview(.basic(image), layoutAlignment)
//            case .profile:
//                return .preview(.profile(image), layoutAlignment)
//            }
//        }
    }
    
    private func modifiedByCoverUploadingEventWith(image: UIImage) -> ObjectHeader? {
        let newCover = ObjectCover.preview(image)
        
        switch self {
        case .iconOnly(let objectIcon):
            return .iconAndCover(icon: objectIcon, cover: newCover)
        case .coverOnly:
            return .coverOnly(newCover)
        case .iconAndCover(let objectIcon, _):
            return .iconAndCover(icon: objectIcon, cover: newCover)
        case .empty:
            return .coverOnly(newCover)
        }
    }
    
}
