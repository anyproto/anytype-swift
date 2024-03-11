import Foundation
import SwiftUI

struct SpaceMembersView: View {
    
    @StateObject var model: SpaceMembersViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.SpaceShare.members)
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(model.rows) { participant in
                        SpaceShareParticipantView(participant: participant)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .task {
            await model.onAppear()
        }
    }
}
