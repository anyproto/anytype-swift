import Services

@MainActor
protocol ObjectSearchWithMetaModuleOutput: AnyObject {
    func onOpenObject(data: EditorScreenData)
}
