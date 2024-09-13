struct AllContentState: Equatable, Hashable {
    var type: AllContentType = .objects
    var sort = AllContentSort(relation: .dateUpdated)
    var limitedObjectsIds: [String]? = nil
}
