import SwiftUI

@MainActor
final class NewInviteLinkCoordinatorViewModel: ObservableObject, NewInviteLinkModuleOutput {
    
    let data: SpaceShareData
    
    @Published var shareInviteLink: URL? = nil
    @Published var qrCodeInviteLink: URL? = nil
    
    init(data: SpaceShareData) {
        self.data = data
    }
    
    // MARK: - NewInviteLinkModuleOutput
    
    func shareInvite(url: URL) {
        shareInviteLink = url
    }
    
    func showQrCode(url: URL) {
        qrCodeInviteLink = url
    }
}