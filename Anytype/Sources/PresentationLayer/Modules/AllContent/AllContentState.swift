struct AllContentState: Equatable, Hashable {
    var mode = AllContentMode.allContent
    var type = AllContentType.objects
    var sort = AllContentSort(relation: .dateUpdated)
    var limitedObjectsIds: [String]? = nil
}
