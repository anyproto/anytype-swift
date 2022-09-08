import BlocksModels
import AnytypeCore

struct SetContentViewItemConfiguration: Identifiable, Hashable {
    let id: BlockId
    let title: String
    let description: String?
    let icon: ObjectIconImage?
    let relationValues: [RelationValue]
    let showIcon: Bool
    let smallItemSize: Bool
    let hasCover: Bool
    let coverFit: Bool
    let coverType: ObjectHeaderCoverType?
    @EquatableNoop var onIconTap: () -> Void
    @EquatableNoop var onItemTap: () -> Void
    
    init(
        id: BlockId,
        title: String,
        description: String?,
        icon: ObjectIconImage?,
        relationValues: [RelationValue],
        showIcon: Bool,
        smallItemSize: Bool,
        hasCover: Bool,
        coverFit: Bool,
        coverType: ObjectHeaderCoverType?,
        onIconTap: @escaping () -> Void,
        onItemTap: @escaping () -> Void
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.relationValues = relationValues
        self.showIcon = showIcon
        self.smallItemSize = smallItemSize
        self.hasCover = hasCover
        self.coverFit = coverFit
        self.coverType = coverType
        self.onIconTap = onIconTap
        self.onItemTap = onItemTap
    }
}
