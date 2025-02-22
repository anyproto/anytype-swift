import SwiftUI

@MainActor
final class InviteLinkCoordinatorViewModel: ObservableObject, InviteLinkModuleOutput {
    
    let data: SpaceShareData
    
    @Published var shareInviteLink: URL? = nil
    @Published var qrCodeInviteLink: URL? = nil
    
    init(data: SpaceShareData) {
        self.data = data
    }
    
    // MARK: - InviteLinkModuleOutput
    
    func shareInvite(url: URL) {
        shareInviteLink = url
    }
    
    func showQrCode(url: URL) {
        qrCodeInviteLink = url
    }
}
