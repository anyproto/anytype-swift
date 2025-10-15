import Foundation
import SwiftUI
import Services

@MainActor
final class SpaceShareCoordinatorViewModel: ObservableObject, InviteLinkModuleOutput {
    
    @Published var showMoreInfo = false
    @Published var shareInviteLink: URL? = nil
    @Published var qrCodeInviteLink: URL? = nil
    
    let data: SpaceShareData
    
    init(data: SpaceShareData) {
        self.data = data
    }
    
    // MARK: - InviteLinkModuleOutput
    
    func onMoreInfoSelected() {
        showMoreInfo = true
    }
    
    func shareInvite(url: URL) {
        shareInviteLink = url
    }
    
    func showQrCode(url: URL) {
        qrCodeInviteLink = url
    }
}
