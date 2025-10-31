import Foundation
import SwiftUI
import Services

@MainActor
final class SpaceShareCoordinatorViewModel: ObservableObject, NewInviteLinkModuleOutput {

    @Published var showMoreInfo = false
    @Published var shareInviteLink: URL? = nil
    @Published var qrCodeInviteLink: URL? = nil
    @Published var presentSpacesManager = false

    let data: SpaceShareData
    
    init(data: SpaceShareData) {
        self.data = data
    }
    
    // MARK: - NewInviteLinkModuleOutput
    
    func onMoreInfoSelected() {
        showMoreInfo = true
    }
    
    func shareInvite(url: URL) {
        shareInviteLink = url
    }
    
    func showQrCode(url: URL) {
        qrCodeInviteLink = url
    }

    func showSpacesManager() {
        presentSpacesManager = true
    }
}
