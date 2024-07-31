import Foundation
import SwiftUI

struct VersionHistoryView: View {
    
    @StateObject private var model: VersionHistoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: VersionHistoryData, output: VersionHistoryModuleOutput?) {
        _model = StateObject(wrappedValue: VersionHistoryViewModel(data: data, output: output))
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
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(model.groups) { group in
                    groupContent(for: group)
                }
            }
        }
        .scrollIndicators(.never)
    }
    
    private func groupContent(for group: VersionHistoryDataGroup) -> some View {
        VersionHistoryGroupContainer(
            title: group.title,
            icons: group.icons,
            content: content(for: group.versions),
            isExpanded: model.expandedGroups.contains(group.title),
            headerAction: {
                model.onGroupTap(group)
            }
        )
        .padding(.horizontal, 20)
    }
    
    private func content(for versions: [[VersionHistoryItem]]) -> some View {
        ForEach(versions, id: \.self) { versions in
            if let version = versions.first {
                itemRow(for: version)
            }
        }
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
        .fixTappableArea()
        .onTapGesture {
            model.onVersionTap(data.id)
        }
    }
}
