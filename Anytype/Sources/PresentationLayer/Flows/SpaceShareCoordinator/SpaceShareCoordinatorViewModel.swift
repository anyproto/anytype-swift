import Foundation
import SwiftUI
import Services

@MainActor
@Observable
final class SpaceShareCoordinatorViewModel: NewInviteLinkModuleOutput {

    var showMoreInfo = false
    var shareInviteLink: URL? = nil
    var qrCodeInviteLink: URL? = nil
    var presentSpacesManager = false

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
