import Foundation
import BlocksModels
import Combine

final class ObjectLayoutPickerViewModel: ObservableObject {
        
    @Published var details: ObjectDetails = ObjectDetails(id: "", values: [:])
    var selectedLayout: DetailsLayout {
        details.layout
    }
    
    // MARK: - Private variables
    
    private let detailsService: ObjectDetailsService
    
    // MARK: - Initializer
    
    init(detailsService: ObjectDetailsService) {
        self.detailsService = detailsService
    }
    
    func didSelectLayout(_ layout: DetailsLayout) {
        detailsService.updateLayout(layout)
    }
    
}
