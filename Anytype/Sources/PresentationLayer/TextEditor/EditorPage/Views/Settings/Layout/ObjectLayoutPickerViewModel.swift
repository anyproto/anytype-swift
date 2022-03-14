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
    
    private(set) var popupLayout: AnytypePopupLayoutType = .intrinsic
    
    private weak var popup: AnytypePopupProxy?
    
    private let detailsService: DetailsServiceProtocol
    
    // MARK: - Initializer
    
    init(detailsService: DetailsServiceProtocol) {
        self.detailsService = detailsService
    }
    
    func didSelectLayout(_ layout: DetailsLayout) {
        Amplitude.instance().logLayoutChange(layout)
        detailsService.setLayout(layout)
    }
    
}

extension ObjectLayoutPickerViewModel: AnytypePopupViewModelProtocol {
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
    func makeContentView() -> UIViewController {
        UIHostingController(rootView: ObjectLayoutPicker(viewModel: self))
    }
    
}
