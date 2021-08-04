
/// Protocol for views to communicate with view model
protocol MarkupViewModelProtocol {
    
    func viewDidLoad()
    func handle(action: MarkupViewModelAction)
}
