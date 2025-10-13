import Foundation
import Services
import Combine

struct WidgetObjectListDetailsData {
    var id: String?
    var title: String?
    var details: [ObjectDetails]
}

struct WidgetObjectListEmptyStateData {
    let title: String
    let subtitle: String
}

enum WidgetObjectListEditMode: Equatable {
    case normal(allowDnd: Bool)
    case editOnly
}

@MainActor
protocol WidgetObjectListInternalViewModelProtocol: AnyObject {
    
    var title: String { get }
    var emptyStateData: WidgetObjectListEmptyStateData { get }
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { get }
    var editorScreenData: EditorScreenData { get }
    var editMode: WidgetObjectListEditMode { get }
    var availableMenuItems: [WidgetObjectListMenuItem] { get }
    
    func onAppear()
    func onDisappear()
    func onMove(from: IndexSet, to: Int)
    func subtitle(for details: ObjectDetails) -> String?
}

extension WidgetObjectListInternalViewModelProtocol {
    var availableMenuItems: [WidgetObjectListMenuItem] { [.moveToBin] }
    func onMove(from: IndexSet, to: Int) {}
    func subtitle(for details: ObjectDetails) -> String? { return nil }
}
