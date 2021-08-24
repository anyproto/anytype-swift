import UIKit

extension ObjectHeader {
    
    func modifiedByLocalEvent(
        _ event: ObjectHeaderLocalEvent,
        onIconTap: @escaping () -> ()
    ) -> ObjectHeader? {
        switch event {
        case .iconUploading(let uIImage):
            return modifiedByIconUploadingEventWith(image: uIImage, onIconTap: onIconTap)
        case .coverUploading(let uIImage):
            return modifiedByCoverUploadingEventWith(image: uIImage)
        }
    }
    
    private func modifiedByIconUploadingEventWith(image: UIImage, onIconTap: @escaping () -> ()) -> ObjectHeader? {
        switch self {
        case .iconOnly(let objectIcon):
            return .iconOnly(modifiedObjectIcon(objectIcon, image))
        case .coverOnly(let objectCover):
            return .iconAndCover(
                icon: ObjectIcon(
                    state: .preview(.basic(image), .left),
                    onTap: onIconTap
                ),
                cover: objectCover
            )
        case .iconAndCover(let objectIcon, let objectCover):
            return .iconAndCover(icon: modifiedObjectIcon(objectIcon, image), cover: objectCover)
        case .empty:
            return .iconOnly(
                ObjectIcon(state: .preview(.profile(image), .left), onTap: onIconTap)
            )
        }
    }
    
    private func modifiedObjectIcon(_ objectIcon: ObjectIcon, _ image: UIImage) -> ObjectIcon {
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
    
    private func modifiedByCoverUploadingEventWith(image: UIImage) -> ObjectHeader? {
        switch self {
        case .iconOnly(let objectIcon):
            return .iconAndCover(icon: objectIcon, cover: .preview(image))
        case .coverOnly:
            return .coverOnly(.preview(image))
        case .iconAndCover(let objectIcon, _):
            return .iconAndCover(icon: objectIcon, cover: .preview(image))
        case .empty:
            return .coverOnly(.preview(image))
        }
    }
    
}
