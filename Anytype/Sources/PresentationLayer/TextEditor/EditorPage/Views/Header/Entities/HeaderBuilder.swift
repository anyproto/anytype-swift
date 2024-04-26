import Services

enum HeaderBuilder {
    static func buildObjectHeader(
        details: ObjectDetails,
        usecase: ObjectIconImageUsecase,
        presentationUsecase: ObjectHeaderEmptyData.ObjectHeaderEmptyUsecase,
        onIconTap: @escaping () -> Void,
        onCoverTap: @escaping () -> Void
    ) -> ObjectHeader {
        let layoutAlign = details.layoutAlignValue
        
        if details.layoutValue == .note {
            return .empty(usecase: presentationUsecase, onTap: {})
        }
        
        let icon = details.layoutValue == .bookmark ? nil : details.icon
        
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
                    )
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
                    )
            )
        }
        
        if let cover = details.documentCover {
            return .filled(state:
                    .coverOnly(
                        ObjectHeaderCover(
                            coverType: .cover(cover),
                            onTap: onCoverTap
                        )
                    )
            )
        }
        
        return .empty(
            data: .init(presentationStyle: presentationUsecase, onTap: onCoverTap),
            isShimmering: false
        )
    }
}
