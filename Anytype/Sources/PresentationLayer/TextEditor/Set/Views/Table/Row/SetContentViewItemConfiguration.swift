import CoreFoundation
import Services
import AnytypeCore

struct SetContentViewItemConfiguration: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String?
    let icon: Icon?
    let relations: [Relation]
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
        description: String?,
        icon: Icon?,
        relations: [Relation],
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
        self.description = description
        self.icon = icon
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
