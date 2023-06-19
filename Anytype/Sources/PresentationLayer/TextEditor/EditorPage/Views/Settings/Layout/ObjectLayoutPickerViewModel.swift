import Foundation
import Services
import Combine
import SwiftUI
import FloatingPanel

final class ObjectLayoutPickerViewModel: ObservableObject {
    var selectedLayout: DetailsLayout {
        document.details?.layoutValue ?? .basic
    }
    
    // MARK: - Private variables
    
    private let document: BaseDocumentProtocol
    private let detailsService: DetailsServiceProtocol
    private var subscription: AnyCancellable?
    
    // MARK: - Initializer
    
    init(document: BaseDocumentProtocol, detailsService: DetailsServiceProtocol) {
        self.document = document
        self.detailsService = detailsService
        
        setupSubscription()
    }
    
    func didSelectLayout(_ layout: DetailsLayout) {
        AnytypeAnalytics.instance().logLayoutChange(layout)
        detailsService.setLayout(layout)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    // MARK: - Private
    private func setupSubscription() {
        subscription = document.updatePublisher.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
}
