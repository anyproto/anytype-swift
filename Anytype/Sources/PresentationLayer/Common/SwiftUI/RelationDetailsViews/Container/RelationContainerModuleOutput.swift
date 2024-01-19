@MainActor
protocol RelationContainerModuleOutput: AnyObject {
    func clear()
    func add()
    func onSearch(_ text: String)
}
