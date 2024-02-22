public final class SearchFiltersBuilder {
    
    public static func build(isArchived: Bool, spaceIds: [String]) -> [DataviewFilter] {
        [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: isArchived),
            SearchHelper.spaceIds(spaceIds)
        ]
    }
    
    public static  func build(isArchived: Bool, spaceId: String) -> [DataviewFilter] {
        build(isArchived: isArchived, spaceIds: [spaceId])
    }
    
    public static func build(isArchived: Bool, spaceIds: [String], layouts: [DetailsLayout]) -> [DataviewFilter] {
        var filters = build(isArchived: isArchived, spaceIds: spaceIds)
        filters.append(SearchHelper.layoutFilter(layouts))
        filters.append(SearchHelper.templateScheme(include: false))
        return filters
    }
    
    public static func build(isArchived: Bool, spaceId: String, layouts: [DetailsLayout]) -> [DataviewFilter] {
        build(isArchived: isArchived, spaceIds: [spaceId], layouts: layouts)
    }
}
