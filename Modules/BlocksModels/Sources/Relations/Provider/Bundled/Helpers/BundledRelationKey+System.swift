import Foundation

// Sync with
// go https://github.com/anytypeio/go-anytype-middleware/blob/master/pkg/lib/bundle/init.go#L18
// and desktop https://github.com/anytypeio/js-anytype/blob/d280e7b88d6c440372094caf9c800c349862f7f9/src/json/constant.json#L66

public extension BundledRelationKey {
    static var systemKeys: [BundledRelationKey] {
        [
            .id,
            .name,
            .description,
            .snippet,
            .type,
            .featuredRelations,
            .workspaceId,
            .sourceObject,
            .done,
            .links,
            .internalFlags,
            .restrictions,

            .setOf,
            .smartblockTypes,
            .targetObjectType,
            .recommendedRelations,
            .recommendedLayout,
            .templateIsBundled,

            .layout,
            .layoutAlign,

            .creator,
            .createdDate,
            .lastOpenedDate,
            .lastModifiedBy,
            .lastModifiedDate,
            .addedDate,

            .iconEmoji,
            .iconImage,
                    
            .coverId,
            .coverType,
            .coverScale,
            .coverX,
            .coverY,

            .fileExt,
            .fileMimeType,
            .sizeInBytes,

            .isHidden,
            .isArchived,
            .isFavorite,
            .isReadonly,

            .relationKey,
            .relationFormat,
            .relationMaxCount,
            .relationReadonlyValue,
            .relationDefaultValue,
            .relationFormatObjectTypes,
            .relationOptionColor
        ]
    }
}
