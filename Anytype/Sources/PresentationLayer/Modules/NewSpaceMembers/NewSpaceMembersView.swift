import Foundation
import SwiftUI

struct NewSpaceMembersView: View {
    
    @StateObject private var model: NewSpaceMembersViewModel
    
    init(data: SpaceMembersData) {
        _model = StateObject(wrappedValue: NewSpaceMembersViewModel(data: data))
    }
    
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
            await model.startParticipantTask()
        }
        .onAppear {
            model.onAppear()
        }
        .anytypeSheet(item: $model.participantInfo) {
            ProfileView(info: $0)
        }
    }
}