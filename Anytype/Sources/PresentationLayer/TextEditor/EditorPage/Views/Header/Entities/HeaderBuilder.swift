import Services

enum HeaderBuilder {
    static func buildObjectHeader(
        details: ObjectDetails,
        usecase: ObjectIconImageUsecase,
        presentationUsecase: ObjectHeaderEmptyUsecase,
        showPublishingBanner: Bool,
        onIconTap: @escaping () -> Void,
        onCoverTap: @escaping () -> Void
    ) -> ObjectHeader {
        let layoutAlign = details.objectAlignValue
        
        if details.resolvedLayoutValue.isNote {
            return .empty(usecase: presentationUsecase, showPublishingBanner: showPublishingBanner, onTap: {})
        }
        
        let icon = details.resolvedLayoutValue.haveIcon ? details.objectIcon : nil
        
        if let icon = icon, let cover = details.documentCover {
            return .filled(state:
                    .iconAndCover(
                        icon: ObjectHeaderIcon(
                            icon: .init(mode: .icon(icon), usecase: usecase),
                            layoutAlignment: layoutAlign,
                            onTap: onIconTap
                        ),
                        cover: ObjectHeaderCover(
                            coverType: .cover(cover),
                            onTap: onCoverTap
                        )
                    ), showPublishingBanner: showPublishingBanner
            )
        }
        
        if let icon = icon {
            return .filled(state:
                    .iconOnly(
                        ObjectHeaderIconOnlyState(
                            icon: ObjectHeaderIcon(
                                icon: .init(mode: .icon(icon), usecase: usecase),
                                layoutAlignment: layoutAlign,
                                onTap: onIconTap
                            ),
                            onCoverTap: onCoverTap
                        )
                    ), showPublishingBanner: showPublishingBanner
            )
        }
        
        if let cover = details.documentCover {
            return .filled(state:
                    .coverOnly(
                        ObjectHeaderCover(
                            coverType: .cover(cover),
                            onTap: onCoverTap
                        )
                    ), showPublishingBanner: showPublishingBanner
            )
        }
        
        return .empty(
            data: ObjectHeaderEmptyData(
                presentationStyle: presentationUsecase,
                onTap: onCoverTap
            ),
            showPublishingBanner: showPublishingBanner,
            isShimmering: false
        )
    }
}
