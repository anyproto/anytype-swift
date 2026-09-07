import Foundation
import SwiftUI
import Services

struct QuickCaptureSpacePickerView: View {

    let spaces: [SpaceView]
    let selectedSpaceId: String?
    let draftSpaceIds: Set<String>
    let isProcessing: Bool
    let onSelect: (SpaceView) -> Void

    @State private var searchText = ""

    private var filteredSpaces: [SpaceView] {
        guard !searchText.isEmpty else { return spaces }
        return spaces.filter { $0.title.localizedStandardContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            SearchBar(
                text: $searchText,
                focused: false,
                placeholder: Loc.search,
                shouldShowDivider: false
            )
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(filteredSpaces) { space in
                        spaceRow(space)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.Background.secondary)
        .presentationCornerRadius(16)
        .presentationDetents([.height(400), .large])
        .presentationDragIndicator(.hidden)
    }

    private func spaceRow(_ space: SpaceView) -> some View {
        Button {
            onSelect(space)
        } label: {
            HStack(spacing: 12) {
                IconView(icon: space.objectIconImage)
                    .frame(width: 48, height: 48)
                QuickCaptureDraftDot()
                    .opacity(draftSpaceIds.contains(space.targetSpaceId) ? 1 : 0)
                AnytypeText(space.title, style: .uxTitle2Regular)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)
                Spacer()
                if space.targetSpaceId == selectedSpaceId {
                    Image(asset: .X24.tick)
                        .foregroundStyle(Color.Control.accent100)
                }
            }
            .frame(height: 64)
        }
        .disabled(isProcessing)
        .accessibilityValue(draftSpaceIds.contains(space.targetSpaceId) ? Loc.QuickCapture.unsentDraft : "")
    }
}

struct QuickCaptureDraftDot: View {
    var body: some View {
        Circle()
            .fill(Color.Pure.orange)
            .frame(width: 6, height: 6)
            .accessibilityHidden(true)
    }
}
