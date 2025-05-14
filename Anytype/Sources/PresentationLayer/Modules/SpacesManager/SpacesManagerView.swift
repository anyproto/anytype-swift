import Foundation
import SwiftUI

struct SpacesManagerView: View {
    
    @StateObject private var model = SpacesManagerViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.Spaces.title)
            ScrollView(showsIndicators: false) {
                Spacer.fixedHeight(10)
                VStack(spacing: 12) {
                    ForEach(model.participantSpaces) { row in
                        SpacesManagerRowView(model: row) {
                            try await model.onDelete(row: row)
                        } onLeave: {
                            try await model.onLeave(row: row)
                        } onCancelRequest: {
                            try await model.onCancelRequest(row: row)
                        } onArchive: {
                            try await model.onArchive(row: row)
                        } onStopSharing: {
                            model.onStopSharing(row: row)
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .task {
            await model.startWorkspacesTask()
        }
        .onAppear {
            model.onAppear()
        }
        .background(Color.Background.primary)
        .anytypeSheet(item: $model.spaceForCancelRequestAlert) { space in
            SpaceCancelRequestAlert(spaceId: space.targetSpaceId)
        }
        .anytypeSheet(item: $model.spaceForStopSharingAlert) { space in
            StopSharingAlert(spaceId: space.targetSpaceId)
        }
        .anytypeSheet(item: $model.spaceForLeaveAlert) { space in
            SpaceLeaveAlert(spaceId: space.targetSpaceId)
        }
        .anytypeSheet(item: $model.spaceViewForDelete) { space in
            SpaceDeleteAlert(spaceId: space.targetSpaceId)
        }
        .sheet(item: $model.exportSpaceUrl) { link in
            ActivityView(activityItems: [link])
        }
    }
}
