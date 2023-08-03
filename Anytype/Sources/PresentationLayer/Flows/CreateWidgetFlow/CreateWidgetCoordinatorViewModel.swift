import Foundation
import SwiftUI

@MainActor
final class CreateWidgetCoordinatorViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let data: CreateWidgetCoordinatorModel
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let widgetTypeModuleAssembly: WidgetTypeModuleAssemblyProtocol
    
    // MARK: - State
    
    @Published var showWidgetTypeData: WidgetTypeModuleCreateModel?
    @Published var dismiss: Bool = false
    
    init(
        data: CreateWidgetCoordinatorModel,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        widgetTypeModuleAssembly: WidgetTypeModuleAssemblyProtocol
    ) {
        self.data = data
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.widgetTypeModuleAssembly = widgetTypeModuleAssembly
    }

    func makeWidgetSourceModule() -> AnyView {
        return newSearchModuleAssembly.widgetSourceSearchModule(
            data: WidgetSourceSearchModuleModel(
                spaceId: data.spaceId,
                context: data.context,
                onSelect: { [weak self] source in
                    self?.showSelectWidgetType(source: source)
                }
            )
        )
    }
    
    func makeWidgetTypeModule(data: WidgetTypeModuleCreateModel) -> AnyView {
        return widgetTypeModuleAssembly.makeCreateWidget(data: data)
    }
    
    // MARK: - Private
    
    private func showSelectWidgetType(source: WidgetSource) {
        showWidgetTypeData = WidgetTypeModuleCreateModel(
            widgetObjectId: data.widgetObjectId,
            source: source,
            position: data.position,
            context: data.context,
            onFinish: { [weak self] in
                self?.dismiss.toggle()
            }
        )
    }
}
