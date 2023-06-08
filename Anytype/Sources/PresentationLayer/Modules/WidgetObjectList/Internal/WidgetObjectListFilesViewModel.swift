import Foundation
import BlocksModels
import Combine

final class WidgetObjectListFilesViewModel: WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let subscriptionService: FilesSubscriptionServiceProtocol
    
    // MARK: - State
    
    let title = Loc.files
    let editorViewType: EditorViewType = .page
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { $rowDetails.eraseToAnyPublisher()}
    let editMode: WidgetObjectListEditMode = .editOnly
    let availableMenuItems: [WidgetObjectListMenuItem] = [.delete]
    
    private var details: [ObjectDetails] = [] {
        didSet { rowDetails = [WidgetObjectListDetailsData(details: details)] }
    }
    @Published private var rowDetails: [WidgetObjectListDetailsData] = []
    
    init(subscriptionService: FilesSubscriptionServiceProtocol) {
        self.subscriptionService = subscriptionService
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        subscriptionService.startSubscription(objectLimit: nil, update: { [weak self] _, update in
            self?.details.applySubscriptionUpdate(update)
        })
    }
    
    func onDisappear() {
        subscriptionService.stopSubscription()
    }
    
    func subtitle(for details: ObjectDetails) -> String? {
        return details.sizeInBytes.map { FileSizeConverter.convert(size: Int64($0)) }
    }
}
