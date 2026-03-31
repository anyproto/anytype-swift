public final class SearchFiltersBuilder {
    
    public static func build(isArchived: Bool) -> [DataviewFilter] {
        .builder {
            SearchHelper.notHiddenFilters(isArchive: isArchived)
        }
    }

    @available(*, deprecated, message: "Use spaceType overload instead")
    public static func build(isArchived: Bool, layouts: [DetailsLayout], spaceUxType: SpaceUxType?) -> [DataviewFilter] {
        var filters = build(isArchived: isArchived)
        filters.append(SearchHelper.layoutFilter(layouts))
        filters.append(SearchHelper.templateScheme(include: false))
        if !spaceUxType.supportsMultiChats {
            filters.append(SearchHelper.filterOutChatType())
        }
        filters.append(SearchHelper.filterOutParticipantType())
        return filters
    }

    public static func build(isArchived: Bool, layouts: [DetailsLayout], spaceType: SpaceType?) -> [DataviewFilter] {
        var filters = build(isArchived: isArchived)
        filters.append(SearchHelper.layoutFilter(layouts))
        filters.append(SearchHelper.templateScheme(include: false))
        if spaceType == .oneToOne {
            filters.append(SearchHelper.filterOutChatType())
        }
        filters.append(SearchHelper.filterOutParticipantType())
        return filters
    }
}
