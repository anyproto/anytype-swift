public final class SearchFiltersBuilder {
    
    public static func buildFilters(isArchived: Bool, spaceIds: [String]) -> [DataviewFilter] {
        [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: isArchived),
            SearchHelper.spaceIds(spaceIds)
        ]
    }
    
    public static  func buildFilters(isArchived: Bool, spaceId: String) -> [DataviewFilter] {
        buildFilters(isArchived: isArchived, spaceIds: [spaceId])
    }
    
    public static func buildFilters(isArchived: Bool, spaceIds: [String], layouts: [DetailsLayout]) -> [DataviewFilter] {
        var filters = buildFilters(isArchived: isArchived, spaceIds: spaceIds)
        filters.append(SearchHelper.layoutFilter(layouts))
        filters.append(SearchHelper.templateScheme(include: false))
        return filters
    }
    
    public static func buildFilters(isArchived: Bool, spaceId: String, layouts: [DetailsLayout]) -> [DataviewFilter] {
        buildFilters(isArchived: isArchived, spaceIds: [spaceId], layouts: layouts)
    }
}
