import Foundation
import Combine

@MainActor
protocol ListWidgetViewModelProtocol: ObservableObject {
    
//    var name: String { get }
    var count: String? { get }
//    var isExpanded: Bool { get set }
    var headerItems: [ListWidgetHeaderItem.Model] { get }
    var rows: [ListWidgetRow.Model] { get }
    // For static widget height
    var minimimRowsCount: Int { get }
    
//    func onAppear()
//    func onDisappear()
    func onDeleteWidgetTap()
}
