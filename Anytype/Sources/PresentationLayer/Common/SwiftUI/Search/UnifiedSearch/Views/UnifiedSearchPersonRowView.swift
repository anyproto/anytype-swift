import SwiftUI
import Services

struct UnifiedSearchPersonRow: Identifiable, Hashable {
    let identity: String
    // The representative participant object (scope/current space preferred)
    let participantObjectId: String
    let spaceId: String
    let title: String
    let icon: Icon
    // Shared channels, the person's own 1:1 not counted
    let sharedChannelCount: Int
    let hasOneToOne: Bool

    var id: String { identity }

    var caption: String? {
        let count: String? = switch sharedChannelCount {
        case ..<1: nil
        case 1: Loc.UnifiedSearch.Person.memberInOneChannel
        default: Loc.UnifiedSearch.Person.memberInChannels(sharedChannelCount)
        }
        if hasOneToOne {
            return count
        }
        // No 1:1 yet - the verb first, the count behind a bullet
        return [Loc.UnifiedSearch.Person.createOneToOne, count].compactMap { $0 }.joined(separator: " · ")
    }
}

struct UnifiedSearchPersonRowView: View {

    let row: UnifiedSearchPersonRow
    // Primary tap opens the participant profile; the drill adds a "By" filter
    let onTap: () -> Void
    let onDrill: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 12) {
                IconView(icon: row.icon)
                    .frame(width: 48, height: 48)
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 0) {
                    AnytypeText(row.title, style: .previewTitle2Medium)
                        .foregroundStyle(Color.Text.primary)
                        .lineLimit(1)
                    if let caption = row.caption {
                        AnytypeText(caption, style: .relation2Regular)
                            .foregroundStyle(Color.Text.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Button {
                    onDrill()
                } label: {
                    Image(asset: .X18.search)
                        .foregroundStyle(Color.Control.secondary)
                        .fixTappableArea()
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Loc.search)
            }
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .fixTappableArea()
            .newDivider()
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }
}
