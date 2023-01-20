import Foundation
import Combine

// Widget will be renamed to List in next PR
@MainActor
protocol ListWidgetViewModelProtocol: ObservableObject {
    
    var name: String { get }
    var isExpanded: Bool { get set }
    var headerItems: [SetWidgetHeaderItem.Model] { get }
    var rows: [SetWidgetRow.Model] { get }
    
    func onAppear()
    func onDisappear()
    func onDeleteWidgetTap()
}
