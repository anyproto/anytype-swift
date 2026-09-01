import SwiftUI

struct UnifiedSearchChipModel: Identifiable, Hashable {
    enum Action: Hashable {
        case addToken(UnifiedSearchToken)
        case openChannelsPicker
        case openPeoplePicker
        case openTypesPicker
    }

    let action: Action
    let title: String
    let icon: Icon?

    init(action: Action, title: String, icon: Icon? = nil) {
        self.action = action
        self.title = title
        self.icon = icon
    }

    init(token: UnifiedSearchToken, title: String, icon: Icon? = nil) {
        self.init(action: .addToken(token), title: title, icon: icon)
    }

    var id: String {
        switch action {
        case .addToken(let token):
            token.id
        case .openChannelsPicker:
            "channels-picker"
        case .openPeoplePicker:
            "people-picker"
        case .openTypesPicker:
            "types-picker"
        }
    }

    static func refinementPackage(
        people: [Self],
        channels: [Self],
        prioritizedChannelSpaceId: String? = nil,
        individualLimit: Int
    ) -> [Self] {
        guard individualLimit > 0 else { return [] }

        let people = Array(people.prefix(individualLimit))
        let channels = Array(
            channels
                .prioritizingSpace(prioritizedChannelSpaceId)
                .prefix(individualLimit)
        )
        var result = [Self]()

        if channels.isNotEmpty {
            result.append(Self(
                action: .openChannelsPicker,
                title: UnifiedSearchKindBucket.channels.title
            ))
        }
        if people.isNotEmpty {
            result.append(Self(
                action: .openPeoplePicker,
                title: Loc.UnifiedSearch.Chip.people,
                icon: .asset(ImageAsset.CustomIcons.people)
            ))
        }

        result.append(contentsOf: people)
        result.append(contentsOf: channels)
        return result
    }
}

private extension Array where Element == UnifiedSearchChipModel {
    func prioritizingSpace(_ spaceId: String?) -> Self {
        guard let spaceId,
              let index = firstIndex(where: { chip in
                  if case .addToken(.space(let candidateSpaceId)) = chip.action {
                      return candidateSpaceId == spaceId
                  }
                  return false
              }),
              index != startIndex else { return self }

        var result = self
        result.insert(result.remove(at: index), at: startIndex)
        return result
    }
}

// Adaptive suggestion row: shows only tokens that could still be added. A chip
// adds its token and disappears; removal happens only on the token's pill.
// No selected state, no toggle-off.
struct UnifiedSearchChipsRowView: View {

    let chips: [UnifiedSearchChipModel]
    let glassNamespace: Namespace.ID
    let onTap: (UnifiedSearchChipModel) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            // Deliberately not lazy: deferred layout inside the glass container
            // detaches the capsules from the bar (the row is a dozen chips at most)
            HStack(spacing: 8) {
                ForEach(chips) { chip in
                    chipView(chip)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
        .animation(.default, value: chips)
    }

    private func chipView(_ chip: UnifiedSearchChipModel) -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            onTap(chip)
        } label: {
            HStack(spacing: 4) {
                if let icon = chip.icon {
                    SearchChipIconView(icon: icon)
                        .frame(width: 16, height: 16)
                }
                AnytypeText(chip.title, style: .uxTitle2Medium)
                    .foregroundStyle(Color.Text.primary)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .chipBackground
            .glassEffectIDIOS26(chip.id, in: glassNamespace)
            .fixTappableArea()
        }
        .buttonStyle(.plain)
    }
}

// Asset glyphs draw at their native size inside IconView and overflow small
// frames - scale them to fit; avatars and object icons render via IconView
struct SearchChipIconView: View {
    let icon: Icon

    var body: some View {
        switch icon {
        case .asset(let asset):
            Image(asset: asset)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.Text.primary)
        default:
            IconView(icon: icon)
        }
    }
}

private extension View {
    @ViewBuilder
    var chipBackground: some View {
        if #available(iOS 26.0, *) {
            // Tappable control - interactive glass (scale/bounce touch response)
            self.glassEffect(.regular.interactive(), in: .capsule)
        } else {
            self
                .background(Color.Shape.transparentSecondary)
                .clipShape(.capsule)
        }
    }
}
