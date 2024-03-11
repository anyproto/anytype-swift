import Foundation
import SwiftUI

struct SpacesManagerView: View {
    
    @StateObject var model: SpacesManagerViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.Spaces.title)
            ScrollView(showsIndicators: false) {
                Spacer.fixedHeight(10)
                VStack(spacing: 12) {
                    ForEach(model.rows) { row in
                        SpacesManagerRowView(model: row) {
                            try await model.onDelete(row: row)
                        } onCancelRequest: {
                            try await model.onCancelRequest(row: row)
                        } onArchive: {
                            try await model.onArchive(row: row)
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .task {
            await model.onAppear()
        }
        .task {
            await model.startWorkspacesTask()
        }
    }
}
