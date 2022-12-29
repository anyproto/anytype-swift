import Foundation

protocol ObjectTreeExpandalbeItemsHelperProtocol {
    func maxExpandalbeItems() -> Int
}

final class ObjectTreeExpandalbeItemsHelper: ObjectTreeExpandalbeItemsHelperProtocol {
    
    private enum Constants {
        static let emptyWidgetHeight = LinkWidgetViewContainer<ObjectTreeWidgetRowView>.emptyHeight()
        static let rowHeight = ObjectTreeWidgetRowView.height()
    }
    
    private let viewControllerProvider: ViewControllerProviderProtocol
    
    init(viewControllerProvider: ViewControllerProviderProtocol) {
        self.viewControllerProvider = viewControllerProvider
    }
    
    // MARK: - ObjectTreeExpandalbeItemsHelperProtocol
    
    func maxExpandalbeItems() -> Int {
        guard let window = viewControllerProvider.window,
              let topViewController = viewControllerProvider.topViewController else { return 0 }
        
        let height = window.frame.height
        let topInset = topViewController.view.safeAreaInsets.top
        let bottomInset = topViewController.view.safeAreaInsets.bottom
        
        let availableHeight = height - topInset - bottomInset - Constants.emptyWidgetHeight
        
        return Int(floor(availableHeight / Constants.rowHeight))
    }
}
