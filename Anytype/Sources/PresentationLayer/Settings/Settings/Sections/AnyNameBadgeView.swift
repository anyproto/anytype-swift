import SwiftUI

enum AnyNameBadgeState {
    case memberName(String)
    case anytypeId(String)

    var displayText: String {
        switch self {
        case .memberName(let name):
            return name
        case .anytypeId(let id):
            guard id.count > 14 else { return id }
            return "\(id.prefix(6))...\(id.suffix(6))"
        }
    }
}

struct AnyNameBadgeView: View {

    let state: AnyNameBadgeState
    let onTap: () -> Void

    var body: some View {
        switch state {
        case .memberName(let name):
            memberBadge(name: name)
        case .anytypeId:
            nonMemberBadge
        }
    }

    private func memberBadge(name: String) -> some View {
        HStack(spacing: 6) {
            Image(asset: .X18.membershipBadge).frame(width: 18, height: 18)
            AnytypeText(name, style: .uxCalloutMedium)
                .foregroundStyle(Color.Text.primary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
    }

    private var nonMemberBadge: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: "questionmark.circle.fill")
                    .frame(width: 18, height: 18)
                    .foregroundStyle(Color.Control.accent100)
                AnytypeText(state.displayText, style: .uxCalloutMedium)
                    .foregroundStyle(Color.Text.primary)
            }
            .padding(.leading, 6)
            .padding(.trailing, 10)
            .padding(.vertical, 5)
            .background(Color.Control.accent25)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
