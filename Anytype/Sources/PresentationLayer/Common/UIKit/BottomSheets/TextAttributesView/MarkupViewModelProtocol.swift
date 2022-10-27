
/// Protocol for views to communicate with view model
protocol MarkupViewModelProtocol {
    func viewLoaded()
    func handle(action: MarupViewAction)
    
}
