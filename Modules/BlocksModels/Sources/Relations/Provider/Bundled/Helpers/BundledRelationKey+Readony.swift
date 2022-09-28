import Foundation

// Sync with
// https://github.com/anytypeio/go-anytype-middleware/blob/4fcbf6754f445b68b8ffa1d7ae4de591f6398ab8/pkg/lib/bundle/init.go#L18

extension BundledRelationKey {
    static var readonlyKeys: [BundledRelationKey] {
        [
            .id,
            .name,
            .description,
            .snippet,
            .iconEmoji,
            .iconImage,
            .type,
            .layout,
            .layoutAlign,
            .coverId,
            .coverScale,
            .coverType,
            .coverX,
            .coverY,
            .createdDate,
            .creator,
            .lastModifiedDate,
            .lastModifiedBy,
            .lastOpenedDate,
            .featuredRelations,
            .isHidden,
            .isArchived,
            .isFavorite,
            .workspaceId,
            .links,
            .internalFlags
        ]
    }
}
