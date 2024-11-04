import SwiftUI

final class ObjectTypeViewModel: ObservableObject {
    @Published var title = ""
    
    private let data: EditorTypeObject
    private let document: any BaseDocumentProtocol
    
    init(data: EditorTypeObject) {
        self.data = data
        self.document = Container.shared.documentService().document(objectId: data.objectId, spaceId: data.spaceId)
    }
    
    func setup() async {
        async let detailsSubscription: () = subscribeOnDetails()
        (_) = await (detailsSubscription) // TBD: more subscriptions will be added here
    }
    
    // MARK: - Private
    func subscribeOnDetails() async {
        for await details in document.detailsPublisher.values {
            title = details.title
        }
    }
}
