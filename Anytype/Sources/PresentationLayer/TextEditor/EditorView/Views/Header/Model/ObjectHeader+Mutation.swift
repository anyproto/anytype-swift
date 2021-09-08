import UIKit

extension ObjectHeader {
    
    func modifiedByLocalEvent(
        _ event: ObjectHeaderLocalEvent,
        onIconTap: @escaping () -> (),
        onCoverTap: @escaping () -> ()
    ) -> ObjectHeader? {
        switch event {
        case .iconUploading(let uIImage):
            return modifiedByIconUploadingEventWith(image: uIImage, onIconTap: onIconTap, onCoverTap: onCoverTap)
        case .coverUploading(let uIImage):
            return modifiedByCoverUploadingEventWith(image: uIImage, onCoverTap: onCoverTap)
        }
    }
    
    private func modifiedByIconUploadingEventWith(
        image: UIImage,
        onIconTap: @escaping () -> (),
        onCoverTap: @escaping () -> ()
    ) -> ObjectHeader? {
        switch self {
        case .iconOnly(let objectIcon):
            return .iconOnly(modifiedObjectIcon(objectIcon, image, onIconTap, onCoverTap))
        case .coverOnly(let objectCover):
            return .iconAndCover(
                icon: modifiedObjectIcon(nil, image, onIconTap, onCoverTap),
                cover: objectCover
            )
        case .iconAndCover(let objectIcon, let objectCover):
            return .iconAndCover(
                icon: modifiedObjectIcon(objectIcon, image, onIconTap, onCoverTap),
                cover: objectCover
            )
        case .empty:
            return .iconOnly(modifiedObjectIcon(nil, image, onIconTap, onCoverTap))
        }
    }
    
    private func modifiedObjectIcon(
        _ objectIcon: ObjectIcon?,
        _ image: UIImage,
        _ onIconTap: @escaping () -> (),
        _ onCoverTap: @escaping () -> ()
    ) -> ObjectIcon {
        guard let objectIcon = objectIcon else {
            return .preview(.basic(image), .left)
        }
        
        switch objectIcon {
        case .icon(let documentIconType, let layoutAlignment):
            switch documentIconType {
            case .basic:
                return .preview(.basic(image), layoutAlignment)
            case .profile:
                return .preview(.profile(image), layoutAlignment)
            case .emoji:
                return .preview(.basic(image), layoutAlignment)
            }
        case .preview(let objectIconPreviewType, let layoutAlignment):
            switch objectIconPreviewType {
            case .basic:
                return .preview(.basic(image), layoutAlignment)
            case .profile:
                return .preview(.profile(image), layoutAlignment)
            }
        }
    }
    
    private func modifiedByCoverUploadingEventWith(
        image: UIImage,
        onCoverTap: @escaping () -> ()
    ) -> ObjectHeader? {
        let newCover = ObjectCover(state: .preview(image), onTap: onCoverTap)
        
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
