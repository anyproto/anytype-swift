
protocol MarkupViewProtocol: AnyObject {
    @MainActor
    func setMarkupState(_ state: MarkupViewsState)
    @MainActor
    func dismiss()
    
}
