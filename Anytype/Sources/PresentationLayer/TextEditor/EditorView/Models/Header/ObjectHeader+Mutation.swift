import UIKit

extension ObjectHeader {
    
    func modifiedByLocalEvent(
        _ event: ObjectHeaderLocalEvent,
        onIconTap: @escaping () -> (),
        onCoverTap: @escaping () -> ()
    ) -> ObjectHeader? {
        switch event {
        case .iconUploading(let uIImage):
            return modifiedByIconUploadingEventWith(image: uIImage, onIconTap: onIconTap)
        case .coverUploading(let uIImage):
            return modifiedByCoverUploadingEventWith(image: uIImage, onCoverTap: onCoverTap)
        }
    }
    
    private func modifiedByIconUploadingEventWith(image: UIImage, onIconTap: @escaping () -> ()) -> ObjectHeader? {
        switch self {
        case .iconOnly(let objectIcon):
            return .iconOnly(modifiedObjectIcon(objectIcon, image, onIconTap))
        case .coverOnly(let objectCover):
            return .iconAndCover(
                icon: modifiedObjectIcon(nil, image, onIconTap),
                cover: objectCover
            )
        case .iconAndCover(let objectIcon, let objectCover):
            return .iconAndCover(
                icon: modifiedObjectIcon(objectIcon, image, onIconTap),
                cover: objectCover
            )
        case .empty:
            return .iconOnly(modifiedObjectIcon(nil, image, onIconTap))
        }
    }
    
    private func modifiedObjectIcon(
        _ objectIcon: ObjectIcon?,
        _ image: UIImage,
        _ onTap: @escaping () -> ()
    ) -> ObjectIcon {
        guard let objectIcon = objectIcon else {
            return ObjectIcon(state: .preview(.basic(image), .left), onTap: onTap)
        }
        
        switch objectIcon.state {
        case .icon(let documentIconType, let layoutAlignment):
            switch documentIconType {
            case .basic:
                return ObjectIcon(
                    state: .preview(.basic(image), layoutAlignment),
                    onTap: objectIcon.onTap
                )
            case .profile:
                return ObjectIcon(
                    state: .preview(.profile(image), layoutAlignment),
                    onTap: objectIcon.onTap
                )
            case .emoji:
                return ObjectIcon(
                    state: .preview(.basic(image), layoutAlignment),
                    onTap: objectIcon.onTap
                )
            }
        case .preview(let objectIconPreviewType, let layoutAlignment):
            switch objectIconPreviewType {
            case .basic:
                return ObjectIcon(
                    state: .preview(.basic(image), layoutAlignment),
                    onTap: objectIcon.onTap
                )
            case .profile:
                return ObjectIcon(
                    state: .preview(.profile(image), layoutAlignment),
                    onTap: objectIcon.onTap
                )
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
