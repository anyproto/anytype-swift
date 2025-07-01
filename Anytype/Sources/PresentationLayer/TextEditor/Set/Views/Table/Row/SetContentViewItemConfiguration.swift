import CoreFoundation
import Services
import AnytypeCore

struct SetContentViewItemConfiguration: Identifiable, Hashable {
    let id: String
    let title: String
    let showTitle: Bool
    let description: String?
    let icon: Icon
    let canEditIcon: Bool
    let relations: [Property]
    let showIcon: Bool
    let isSmallCardSize: Bool
    let hasCover: Bool
    let coverFit: Bool
    let coverType: ObjectHeaderCoverType?
    let minHeight: CGFloat?
    @EquatableNoop var onItemTap: @MainActor () -> Void
    
    init(
        id: String,
        title: String,
        showTitle: Bool,
        description: String?,
        icon: Icon,
        canEditIcon: Bool,
        relations: [Property],
        showIcon: Bool,
        isSmallCardSize: Bool,
        hasCover: Bool,
        coverFit: Bool,
        coverType: ObjectHeaderCoverType?,
        minHeight: CGFloat?,
        onItemTap: @escaping @MainActor () -> Void
    ) {
        self.id = id
        self.title = title
        self.showTitle = showTitle
        self.description = description
        self.icon = icon
        self.canEditIcon = canEditIcon
        self.relations = relations
        self.showIcon = showIcon
        self.isSmallCardSize = isSmallCardSize
        self.hasCover = hasCover
        self.coverFit = coverFit
        self.coverType = coverType
        self.minHeight = minHeight
        self.onItemTap = onItemTap
    }
}

extension SetContentViewItemConfiguration {
    var shouldIncreaseCoverHeight: Bool {
        hasCover && coverType.isNotNil && hasNoInfo
    }
    
    var hasInfo: Bool {
        !hasNoInfo
    }
    
    private var hasNoInfo: Bool {
        !showTitle && !showIcon && !hasOneRelationWithValueAtLeast
    }
    
    private var hasOneRelationWithValueAtLeast: Bool {
        relations.first { $0.hasValue } != nil
    }
}
