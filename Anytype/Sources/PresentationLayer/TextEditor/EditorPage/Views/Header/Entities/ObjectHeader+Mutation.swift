import UIKit

extension ObjectHeader {
    
    func modifiedByUpdate(
        _ update: ObjectHeaderUpdate,
        onIconTap: @escaping () -> (),
        onCoverTap: @escaping () -> ()
    ) -> ObjectHeader? {
        switch update {
        case .iconUploading(let path):
            return modifiedByIconUploadingEventWith(
                image: UIImage(contentsOfFile: path),
                onIconTap: onIconTap,
                onCoverTap: onCoverTap
            )
        case .coverUploading(let update):
            switch update {
            case .bundleImagePath(let string):
                return modifiedByCoverUploadingEventWith(
                    previewType: .image(UIImage(contentsOfFile: string)),
                    onCoverTap: onCoverTap
                )
            case .remotePreviewURL(let uRL):
                return modifiedByCoverUploadingEventWith(
                    previewType: .remote(uRL),
                    onCoverTap: onCoverTap
                )
            }
        }
    }
    
    private func modifiedByIconUploadingEventWith(
        image: UIImage?,
        onIconTap: @escaping () -> (),
        onCoverTap: @escaping () -> ()
    ) -> ObjectHeader? {
        switch self {
        case .filled(let filledState, _):
            return .filled(state:
                filledState.modifiedByIconUploadingEventWith(
                    image: image,
                    onIconTap: onIconTap
                )
            )
            
        case .empty:
            return .filled(state:
                .iconOnly(
                    ObjectHeaderIconOnlyState(
                        icon: ObjectHeaderIcon(
                            icon: .basicPreview(image),
                            layoutAlignment: .left,
                            onTap: onIconTap
                        ),
                        onCoverTap: onCoverTap
                    )
                )
            )
        }
    }
    
    private func modifiedByCoverUploadingEventWith(
        previewType: ObjectHeaderCoverPreviewType,
        onCoverTap: @escaping () -> ()
    ) -> ObjectHeader? {
        let newCover = ObjectHeaderCover(
            coverType: .preview(previewType),
            onTap: onCoverTap
        )
        
        switch self {
        case .filled(let filledState, _):
            switch filledState {
            case .iconOnly(let objectHeaderIconState):
                return .filled(state: .iconAndCover(icon: objectHeaderIconState.icon, cover: newCover))
            case .coverOnly:
                return .filled(state: .coverOnly(newCover))
            case .iconAndCover(let objectHeaderIcon, _):
                return .filled(state: .iconAndCover(icon: objectHeaderIcon, cover: newCover))
            }
            
        case .empty:
            return .filled(state: .coverOnly(newCover))
        }
    }
    
}

private extension ObjectHeaderFilledState {
    
    func modifiedByIconUploadingEventWith(
        image: UIImage?,
        onIconTap: @escaping () -> ()
    ) -> ObjectHeaderFilledState {
        switch self {
        case .iconOnly(let objectHeaderIconOnlyState):
            return .iconOnly(
                ObjectHeaderIconOnlyState(
                    icon: objectHeaderIconOnlyState.icon.modifiedBy(previewImage: image),
                    onCoverTap: objectHeaderIconOnlyState.onCoverTap
                )
            )
            
        case .coverOnly(let objectCover):
            return .iconAndCover(
                icon: ObjectHeaderIcon(
                    icon: .basicPreview(image),
                    layoutAlignment: .left,
                    onTap: onIconTap
                ),
                cover: objectCover
            )
            
        case .iconAndCover(let objectHeaderIcon, let objectCover):
            return .iconAndCover(
                icon: objectHeaderIcon.modifiedBy(previewImage: image),
                cover: objectCover
            )
        }
    }
    
}

private extension ObjectHeaderIcon {
    
    func modifiedBy(previewImage image: UIImage?) -> ObjectHeaderIcon {
        switch self.icon {
        case .icon(let objectIconType):
            switch objectIconType {
            case .basic:
                return ObjectHeaderIcon(
                    icon: .basicPreview(image),
                    layoutAlignment: self.layoutAlignment,
                    onTap: self.onTap
                )
            case .profile:
                return ObjectHeaderIcon(
                    icon: .profilePreview(image),
                    layoutAlignment: self.layoutAlignment,
                    onTap: self.onTap
                )
            case .emoji:
                return ObjectHeaderIcon(
                    icon: .basicPreview(image),
                    layoutAlignment: self.layoutAlignment,
                    onTap: self.onTap
                )
            }
        case .basicPreview:
            return ObjectHeaderIcon(
                icon: .basicPreview(image),
                layoutAlignment: self.layoutAlignment,
                onTap: self.onTap
            )
        case .profilePreview:
            return ObjectHeaderIcon(
                icon: .profilePreview(image),
                layoutAlignment: self.layoutAlignment,
                onTap: self.onTap
            )
        case .image:
            return ObjectHeaderIcon(
                icon: .basicPreview(image),
                layoutAlignment: self.layoutAlignment,
                onTap: self.onTap
            )
        }
    }
    
}
