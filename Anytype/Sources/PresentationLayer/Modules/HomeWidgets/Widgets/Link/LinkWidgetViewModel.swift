import Foundation

@MainActor
final class LinkWidgetViewModel: ObservableObject, WidgetContainerContentViewModelProtocol {
    
    @Published var name = "Link widget name"
    let allowContent = false
    
    // MARK: - WidgetContainerContentViewModelProtocol

    func onAppear() {
        
    }
    
    func onDisappear() {
        
    }
}
