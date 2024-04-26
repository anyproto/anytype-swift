import Foundation
import Services
import Combine
import AnytypeCore

enum ObjectCoverPickerAction {
    enum CoverSource {
        case color(colorName: String)
        case gradient(gradientName: String)
        case upload(itemProvider: NSItemProvider)
        case unsplash(unsplashItem: UnsplashItem)
    }
    
    case setCover(CoverSource)
    case removeCover
}

final class ObjectCoverPickerViewModel: ObservableObject {
    
    let mediaPickerContentType: MediaPickerContentType = .images
    var isRemoveButtonAvailable: Bool { document.details?.documentCover != nil }

    // MARK: - Private variables
    private let document: BaseDocumentGeneralProtocol
    private let onCoverAction: (ObjectCoverPickerAction) -> Void
        
    // MARK: - Initializer
    
    init(
        document: BaseDocumentGeneralProtocol,
        onCoverAction: @escaping (ObjectCoverPickerAction) -> Void
    ) {
        self.document = document
        self.onCoverAction = onCoverAction
    }
}

extension ObjectCoverPickerViewModel {
    
    func setColor(_ colorName: String) {
        onCoverAction(.setCover(.color(colorName: colorName)))
    }
    
    func setGradient(_ gradientName: String) {
        onCoverAction(.setCover(.gradient(gradientName: gradientName)))
    }
    
    func uploadImage(from itemProvider: NSItemProvider) {
        onCoverAction(.setCover(.upload(itemProvider: itemProvider)))
    }

    func uploadUnplashCover(unsplashItem: UnsplashItem) {
        onCoverAction(.setCover(.unsplash(unsplashItem: unsplashItem)))
    }
    
    func removeCover() {
        onCoverAction(.removeCover)
    }
}
