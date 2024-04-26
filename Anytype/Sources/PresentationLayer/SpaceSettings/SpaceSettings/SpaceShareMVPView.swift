import Foundation
import SwiftUI
import ProtobufMessages
import Services

// This is temporary code for testing
struct SpaceShareMVPView: View {
    
    private let parser = ServiceLocator.shared.deepLinkParser()
    private let workspaceService = ServiceLocator.shared.workspaceService()
    private let activeWorkspaceService = ServiceLocator.shared.activeWorkspaceStorage()
    
    @State private var link: String = ""
    @State private var identityId: String = ""
    
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
            
            AnytypeTextField(placeholder: "Identity id", placeholderFont: .heading, text: $identityId)
                .foregroundColor(.Text.primary)
                .font(AnytypeFontBuilder.font(anytypeFont: .heading))
                .autocorrectionDisabled()
            
            StandardButton(.text("Accept invite"), style: .primaryMedium) {
                Task {
                    try await workspaceService.requestApprove(spaceId: activeWorkspaceService.workspaceInfo.accountSpaceId, identity: identityId)
                }
            }
            
        }
    }
}
