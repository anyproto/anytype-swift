import Foundation
import SwiftUI

struct VersionHistoryView: View {
    
    @StateObject private var model: VersionHistoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(objectId: String) {
        _model = StateObject(wrappedValue: VersionHistoryViewModel(objectId: objectId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.VersionHistory.title)
            versions
        }
        .task {
            await model.startParticipantsSubscription()
        }
        .task {
            await model.getVersions()
        }
    }
    
    private var versions: some View {
        PlainList {
            ForEach(model.versions) { version in
                itemRow(for: version)
            }
        }
        .scrollIndicators(.never)
    }
    
    private func itemRow(for data: VersionHistoryItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(data.time, style: .uxTitle2Medium)
                    .foregroundColor(.Text.primary)
                AnytypeText(data.author, style: .caption1Regular)
                    .foregroundColor(.Text.secondary)
            }
            
            Spacer()
            
            ObjectIconView(icon: data.icon)
                .frame(width: 24, height: 24)
        }
        .padding(.vertical, 9)
        .newDivider()
        .padding(.horizontal, 20)
    }
}
