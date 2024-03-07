import Foundation
import SwiftUI

protocol DateRelationCalendarModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(
        date: Date?,
        configuration: RelationModuleConfiguration
    ) -> AnyView
}

final class DateRelationCalendarModuleAssembly: DateRelationCalendarModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - DateRelationCalendarModuleAssemblyProtocol
    
    @MainActor
    func make(
        date: Date?,
        configuration: RelationModuleConfiguration
    ) -> AnyView {
        DateRelationCalendarView(
            viewModel: DateRelationCalendarViewModel(
                date: date,
                configuration: configuration,
                relationsService: self.serviceLocator.relationService()
            )
        ).eraseToAnyView()
    }
}
