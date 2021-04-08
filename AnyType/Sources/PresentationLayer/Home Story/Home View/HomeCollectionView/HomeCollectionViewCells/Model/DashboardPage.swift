struct DashboardPage: Hashable {
    var id: String
    var targetBlockId: String
    static var empty: Self = .init(id: "", targetBlockId: "")
}
