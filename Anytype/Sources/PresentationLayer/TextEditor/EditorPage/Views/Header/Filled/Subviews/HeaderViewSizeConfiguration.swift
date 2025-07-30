import UIKit

struct HeaderViewSizeConfiguration: Hashable {
    let width: CGFloat
    let fullHeight: CGFloat
    let coverBottomInset: CGFloat
    let coverHeight: CGFloat
    let iconBottomInset: CGFloat
    let iconHorizontalInset: CGFloat
    let onlyIconTopInset: CGFloat
    let iconBorderWidth: CGFloat
    let iconBorderColor: UIColor
}

extension HeaderViewSizeConfiguration {
    static func editorSizeConfiguration(width: CGFloat, showPublishingBanner: Bool) -> HeaderViewSizeConfiguration {
        let bannerOffset = showPublishingBanner ? 30 : 0
        
        return HeaderViewSizeConfiguration(
            width: width,
            fullHeight: ObjectHeaderConstants.coverFullHeight,
            coverBottomInset: ObjectHeaderConstants.coverBottomInset,
            coverHeight: ObjectHeaderConstants.coverHeight,
            iconBottomInset: ObjectHeaderConstants.iconBottomInset,
            iconHorizontalInset: ObjectHeaderConstants.iconHorizontalInset,
            onlyIconTopInset: bannerOffset + ObjectHeaderConstants.emptyViewHeight,
            iconBorderWidth: 4,
            iconBorderColor: .Background.primary
        )
    }
    
    static let templatePreviewSizeConfiguration = HeaderViewSizeConfiguration(
        width: 120,
        fullHeight: 82,
        coverBottomInset: 8,
        coverHeight: 74,
        iconBottomInset: 0,
        iconHorizontalInset: 16,
        onlyIconTopInset: 28,
        iconBorderWidth: 2,
        iconBorderColor: .Background.secondary
    )
}
