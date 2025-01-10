import Foundation
import SwiftUI
import AnytypeCore

@MainActor
final class CreateWidgetCoordinatorViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let data: CreateWidgetCoordinatorModel
    private let onOpenObject: (_ openObject: ScreenData?) -> Void
    
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
    
    init(data: CreateWidgetCoordinatorModel, onOpenObject: @escaping (_ openObject: ScreenData?) -> Void) {
        self.data = data
        self.onOpenObject = onOpenObject
    }
    
    func onSelectSource(source: WidgetSource, openObject: ScreenData?) {
        onOpenObject(openObject)
        dismiss.toggle()
    }
}
