
/// Protocol for views to communicate with view model

@MainActor
protocol MarkupViewModelProtocol {
    func viewLoaded()
    func handle(action: MarupViewAction)
    
}
