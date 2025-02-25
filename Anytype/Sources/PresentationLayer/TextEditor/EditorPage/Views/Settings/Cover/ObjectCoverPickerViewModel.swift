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

struct BaseDocumentIdentifiable: Identifiable {
    let document: any BaseDocumentProtocol
    
    var id: String { document.objectId }
}

extension BaseDocumentProtocol {
    var identifiable: BaseDocumentIdentifiable {
        BaseDocumentIdentifiable(document: self)
    }
}

@MainActor
final class ObjectCoverPickerViewModel: ObservableObject {
    
    let mediaPickerContentType: MediaPickerContentType = .images
    var isRemoveButtonAvailable: Bool { document.details?.documentCover != nil }

    // MARK: - Private variables
    @Injected(\.objectHeaderUploadingService)
    private var objectHeaderUploadingService: any ObjectHeaderUploadingServiceProtocol
    
    private let document: any BaseDocumentProtocol
        
    // MARK: - Initializer
    
    init(data: BaseDocumentIdentifiable) {
        self.document = data.document
    }
}

extension ObjectCoverPickerViewModel {
    
    func setColor(_ colorName: String) {
        Task {
            try await objectHeaderUploadingService.handleCoverAction(
                objectId: document.objectId,
                spaceId: document.spaceId,
                action: .setCover(.color(colorName: colorName))
            )
        }
    }
    
    func setGradient(_ gradientName: String) {
        Task {
            try await objectHeaderUploadingService.handleCoverAction(
                objectId: document.objectId,
                spaceId: document.spaceId,
                action: .setCover(.gradient(gradientName: gradientName))
            )
        }
    }
    
    func uploadImage(from itemProvider: NSItemProvider) {
        let safeItemProvoder = itemProvider.sendable()
        Task {
            try await objectHeaderUploadingService.handleCoverAction(
                objectId: document.objectId,
                spaceId: document.spaceId,
                action: .setCover(.upload(itemProvider: safeItemProvoder.value))
            )
        }
    }

    func uploadUnplashCover(unsplashItem: UnsplashItem) {
        Task {
            try await objectHeaderUploadingService.handleCoverAction(
                objectId: document.objectId,
                spaceId: document.spaceId,
                action: .setCover(.unsplash(unsplashItem: unsplashItem))
            )
        }
    }
    
    func removeCover() {
        Task {
            try await objectHeaderUploadingService.handleCoverAction(
                objectId: document.objectId,
                spaceId: document.spaceId,
                action: .removeCover
            )
        }
    }
}
