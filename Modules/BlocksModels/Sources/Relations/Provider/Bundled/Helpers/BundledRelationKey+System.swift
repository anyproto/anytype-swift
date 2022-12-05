import Foundation

// Sync with
// https://github.com/anytypeio/go-anytype-middleware/blob/master/pkg/lib/bundle/init.go#L18
// and desktop

public extension BundledRelationKey {
    static var systemKeys: [BundledRelationKey] {
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
            .internalFlags,
            .addedDate,
            .done
        ]
    }
}
