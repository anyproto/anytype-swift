import Foundation
import SwiftUI

protocol DateRelationCalendarModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(
        objectId: String,
        title: String,
        date: Date?,
        relationKey: String,
        analyticsType: AnalyticsEventsRelationType
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
        objectId: String,
        title: String,
        date: Date?,
        relationKey: String,
        analyticsType: AnalyticsEventsRelationType
    ) -> AnyView {
        let view = DateRelationCalendarView(
            viewModel: DateRelationCalendarViewModel(
                title: title,
                date: date,
                objectId: objectId,
                relationKey: relationKey,
                relationsService: self.serviceLocator.relationService(),
                analyticsType: analyticsType
            )
        )
        return view.eraseToAnyView()
    }
}
