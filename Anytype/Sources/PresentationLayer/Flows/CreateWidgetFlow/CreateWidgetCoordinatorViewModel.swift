import Foundation
import SwiftUI
import AnytypeCore

@MainActor
final class CreateWidgetCoordinatorViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let data: CreateWidgetCoordinatorModel
    
    // MARK: - State
    
    lazy var widgetSourceSearchData = {
        WidgetSourceSearchModuleModel(
            spaceId: data.spaceId,
            widgetObjectId: data.widgetObjectId,
            position: data.position,
            context: data.context
        )
    }()
    
    @Published var dismiss: Bool = false
    
    init(data: CreateWidgetCoordinatorModel) {
        self.data = data
    }
    
    func onSelectSource(source: WidgetSource) {
        dismiss.toggle()
    }
}
