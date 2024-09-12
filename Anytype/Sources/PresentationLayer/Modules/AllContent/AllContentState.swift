struct AllContentState: Equatable, Hashable {
    var type: AllContentType = .objects
    var limitedObjectsIds: [String]? = nil
}
