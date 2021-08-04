
/// Protocol for views to communicate with view model
protocol MarkupViewModelProtocol {
    
    func viewDidBecomeReadyToUse()
    func handle(action: MarkupViewModelAction)
    
}
