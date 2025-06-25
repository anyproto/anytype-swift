import Foundation
import SwiftUI
import Services
import AnytypeCore

@MainActor
final class GalleryInstallationCoordinatorViewModel: ObservableObject,
                                                     GalleryInstallationPreviewModuleOutput, GallerySpaceSelectionModuleOutput {
    
    let data: GalleryInstallationData
    @Injected(\.galleryService)
    private var galleryService: any GalleryServiceProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    
    private var manifest: GalleryManifest?
    @Published var dismiss = false
    @Published var showSpaceSelection = false
    
    init(data: GalleryInstallationData) {
        self.data = data
    }
    
    // MARK: - GalleryInstallationPreviewModuleOutput
    
    func onSelectInstall(manifest: GalleryManifest) {
        self.manifest = manifest
        showSpaceSelection = true
    }
    
    // MARK: - GallerySpaceSelectionModuleOutput
    
    func onSelectSpace(result: GallerySpaceSelectionResult) {
        guard let manifest else {
            anytypeAssertionFailure("Manifest is empty")
            return
        }
        Task {
            switch result {
            case .space(let spaceId):
                dismiss.toggle()
                try await galleryService.importExperience(spaceId: spaceId, isNewSpace: false, title: manifest.title, url: manifest.downloadLink)
            case .newSpace:
                let createResponse = try await workspaceService.createSpace(
                    name: manifest.title,
                    iconOption: IconColorStorage.randomOption(),
                    accessType: .personal,
                    useCase: .none,
                    withChat: FeatureFlags.homeSpaceLevelChat,
                    uxType: .data
                )
                AnytypeAnalytics.instance().logCreateSpace(spaceId: createResponse.spaceID, spaceUxType: .data, route: .gallery, )
                dismiss.toggle()
                try await galleryService.importExperience(spaceId: createResponse.spaceID, isNewSpace: true, title: manifest.title, url: manifest.downloadLink)
            }
            AnytypeAnalytics.instance().logGalleryInstall(name: manifest.title)
        }
    }
}
