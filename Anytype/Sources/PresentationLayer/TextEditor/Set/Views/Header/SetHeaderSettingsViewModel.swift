import Foundation
import Combine
import Services

class SetHeaderSettingsViewModel: ObservableObject {
    @Published var viewName = ""
    @Published var isActive: Bool = true
    @Published var isTemplatesSelectionAvailable: Bool = false
    
    private let setDocument: SetDocumentProtocol
    private var subscriptions = [AnyCancellable]()
    
    let onViewTap: () -> Void
    let onSettingsTap: () -> Void
    let onCreateTap: () -> Void
    let onSecondaryCreateTap: () -> Void
    
    init(
        setDocument: SetDocumentProtocol,
        isActive: Bool,
        onViewTap: @escaping () -> Void,
        onSettingsTap: @escaping () -> Void,
        onCreateTap: @escaping () -> Void,
        onSecondaryCreateTap: @escaping () -> Void
    ) {
        self.setDocument = setDocument
        self.isActive = isActive
        self.onViewTap = onViewTap
        self.onSettingsTap = onSettingsTap
        self.onCreateTap = onCreateTap
        self.onSecondaryCreateTap = onSecondaryCreateTap
        self.setup()
    }
    
    private func setup() {
        setDocument.activeViewPublisher
            .sink { [weak self] view in
                self?.viewName = view.name
            }
            .store(in: &subscriptions)
        
        setDocument.detailsPublisher
            .sink { [weak self] details in
                self?.isActive = details.setOf.first { $0.isNotEmpty } != nil
                
                self?.isTemplatesSelectionAvailable = ObjectTypeId.BundledTypeId.isTemplatesAvailable(for: details.setOf)
            }
            .store(in: &subscriptions)
    }
}

fileprivate extension ObjectTypeId.BundledTypeId {
    static func isTemplatesAvailable(for setOf: [ObjectId]) -> Bool {
        !unavailableTemplatesSelection.contains {
            setOf.contains($0.rawValue)
        }
    }
    
    static var unavailableTemplatesSelection: [Self] {
        return [.audio, .file, .image, .video, .collection, .set, .bookmark, .space, .dashboard]
    }
}
