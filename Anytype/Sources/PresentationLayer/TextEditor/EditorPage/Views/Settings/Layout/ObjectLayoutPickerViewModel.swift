import Foundation
import BlocksModels
import Combine

final class ObjectLayoutPickerViewModel: ObservableObject {
        
    @Published var details: DetailsDataProtocol = DetailsData.empty
    var selectedLayout: DetailsLayout {
        details.layout ?? .basic
    }
    
    // MARK: - Private variables
    
    private let detailsService: ObjectDetailsService
    
    // MARK: - Initializer
    
    init(detailsService: ObjectDetailsService) {
        self.detailsService = detailsService
    }
    
    func didSelectLayout(_ layout: DetailsLayout) {
        detailsService.update(details: [.layout(layout)])
    }
    
}
