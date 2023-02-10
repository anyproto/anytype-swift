import Foundation
import Combine

@MainActor
protocol ListWidgetViewModelProtocol: ObservableObject {
    
    var headerItems: [ListWidgetHeaderItem.Model] { get }
    var rows: [ListWidgetRow.Model] { get }
    var minimimRowsCount: Int { get }
    
    func onAppearContent()
    func onDisappearContent()
}

// Default implementation

extension ListWidgetViewModelProtocol {
    var headerItems: [ListWidgetHeaderItem.Model] { [] }
}
