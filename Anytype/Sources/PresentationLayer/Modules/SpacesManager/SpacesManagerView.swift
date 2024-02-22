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
                    ForEach(model.spaces) { space in
                        SpacesManagerRowView(spaceView: space)
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .task {
            await model.startWorkspacesTask()
        }
    }
}
