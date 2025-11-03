import Services

extension SearchHelper {

    static func defaultObjectTypeSort(spaceUxType: SpaceUxType?) -> [DataviewSort] {
        let nameSort = SearchHelper.sort(relation: .name, type: .asc)

        let showsChatLayouts = spaceUxType?.showsChatLayouts ?? true
        let customSort = !showsChatLayouts
            ? SearchHelper.customSort(relationKey: BundledPropertyKey.uniqueKey.rawValue, values: [
                ObjectTypeUniqueKey.image.value,
                ObjectTypeUniqueKey.bookmark.value,
                ObjectTypeUniqueKey.file.value,
                ObjectTypeUniqueKey.page.value,
                ObjectTypeUniqueKey.note.value,
                ObjectTypeUniqueKey.task.value,
                ObjectTypeUniqueKey.collection.value,
                ObjectTypeUniqueKey.set.value,
                ObjectTypeUniqueKey.project.value,
                ObjectTypeUniqueKey.video.value,
                ObjectTypeUniqueKey.audio.value
            ])
            : SearchHelper.customSort(relationKey: BundledPropertyKey.uniqueKey.rawValue, values: [
                ObjectTypeUniqueKey.page.value,
                ObjectTypeUniqueKey.note.value,
                ObjectTypeUniqueKey.task.value,
                ObjectTypeUniqueKey.collection.value,
                ObjectTypeUniqueKey.set.value,
                ObjectTypeUniqueKey.bookmark.value,
                ObjectTypeUniqueKey.project.value,
                ObjectTypeUniqueKey.image.value,
                ObjectTypeUniqueKey.file.value,
                ObjectTypeUniqueKey.video.value,
                ObjectTypeUniqueKey.audio.value,
                ObjectTypeUniqueKey.chatDerived.value
            ])
        
        let orderIdSort = SearchHelper.sort(relation: .orderId, type: .asc, emptyPlacement: .end)
        
        return [orderIdSort, customSort, nameSort]
    }
}
