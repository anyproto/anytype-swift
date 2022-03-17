import Foundation
import BlocksModels
import Combine
import Amplitude
import SwiftUI
import FloatingPanel

final class ObjectLayoutPickerViewModel: ObservableObject {
    var selectedLayout: DetailsLayout {
        document.details?.layout ?? .basic
    }
    
    // MARK: - Private variables
    
    private(set) var popupLayout: AnytypePopupLayoutType = .intrinsic
    private weak var popup: AnytypePopupProxy?
    
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
        Amplitude.instance().logLayoutChange(layout)
        detailsService.setLayout(layout)
    }
    
    // MARK: - Private
    private func setupSubscription() {
        subscription = document.updatePublisher.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
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
