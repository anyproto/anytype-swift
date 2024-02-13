import Foundation
import SwiftUI

// This is temporary code for testing
struct SpaceJoinMVPView: View {
    
    @State private var link: String = ""
    
    private let parser = ServiceLocator.shared.deepLinkParser()
    private let workspaceService = ServiceLocator.shared.workspaceService()
    
    var body: some View {
        VStack(spacing: 0) {
            AnytypeTextField(placeholder: "Link", placeholderFont: .heading, text: $link)
                .foregroundColor(.Text.primary)
                .font(AnytypeFontBuilder.font(anytypeFont: .heading))
                .autocorrectionDisabled()
            
            StandardButton(.text("Join"), style: .secondaryMedium) {
                guard let url = URL(string: link) else { return }
                guard let deeplink = parser.parse(url: url) else { return }
                switch deeplink {
                case .invite(let cid, let key):
                    Task {
                        let spaceView = try await workspaceService.inviteView(cid: cid, key: key)
                        try await workspaceService.join(spaceId: spaceView.spaceId, cid: cid, key: key)
                    }
                default:
                    break
                }
            }
        }
    }
}
