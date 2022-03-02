import Foundation
import BlocksModels
import Combine
import Amplitude
import SwiftUI
import FloatingPanel

final class ObjectLayoutPickerViewModel: ObservableObject {
        
    @Published var details: ObjectDetails = ObjectDetails(id: "", values: [:])
    
    var selectedLayout: DetailsLayout {
        details.layout
    }
    
    // MARK: - Private variables
    
    private(set) var popupLayout: FloatingPanelLayout = IntrinsicPopupLayout()
    
    private weak var сontentDelegate: AnytypePopupContentDelegate?
    
    private let detailsService: DetailsService
    
    // MARK: - Initializer
    
    init(detailsService: DetailsService) {
        self.detailsService = detailsService
    }
    
    func didSelectLayout(_ layout: DetailsLayout) {
        Amplitude.instance().logLayoutChange(layout)
        detailsService.setLayout(layout)
    }
    
}

extension ObjectLayoutPickerViewModel: AnytypePopupViewModelProtocol {
    
    func setContentDelegate(_ сontentDelegate: AnytypePopupContentDelegate) {
        self.сontentDelegate = сontentDelegate
    }
    
    func makeContentView() -> UIViewController {
        UIHostingController(rootView: ObjectLayoutPicker(viewModel: self))
    }
    
}
