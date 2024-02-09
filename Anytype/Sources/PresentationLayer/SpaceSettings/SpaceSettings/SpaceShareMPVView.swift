import Foundation
import SwiftUI

// This is temporary code for testing
struct SpaceShareMPVView: View {
    
    private let parser = ServiceLocator.shared.deepLinkParser()
    private let workspaceService = ServiceLocator.shared.workspaceService()
    private let activeWorkspaceService = ServiceLocator.shared.activeWorkspaceStorage()
    
    @State private var link: String = ""
    
    var body: some View {
        VStack {
            Text("Invite link:")
            
            Text(link)
            
            StandardButton(.text("Generate invite link"), style: .primaryMedium) {
                Task {
                    let invite = try await workspaceService.generateInvite(spaceId: activeWorkspaceService.workspaceInfo.accountSpaceId)
                    link = parser.createUrl(deepLink: .invite(cid: invite.cid, key: invite.fileKey))?.absoluteString ?? ""
                }
            }
            
            StandardButton(.text("Copy to buffer"), style: .primaryMedium) {
                UIPasteboard.general.string = link
            }
        }
    }
}
