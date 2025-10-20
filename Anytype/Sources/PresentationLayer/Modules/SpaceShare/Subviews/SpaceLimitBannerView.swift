import SwiftUI
import DesignKit

enum SpaceLimitBannerLimitType: Equatable {
    case sharedSpaces(limit: Int)
    case editors(limit: Int)

    var titleText: String {
        switch self {
        case .sharedSpaces(let limit):
            Loc.SpaceLimit.SharedSpaces.title(limit)
        case .editors(let limit):
            Loc.SpaceLimit.Editors.title(limit)
        }
    }

    var subtitleText: String {
        switch self {
        case .sharedSpaces:
            return Loc.SpaceLimit.SharedSpaces.subtitle
        case .editors:
            return Loc.SpaceLimit.Editors.subtitle
        }
    }

    var showManageButton: Bool {
        switch self {
        case .sharedSpaces:
            return true
        case .editors:
            return false
        }
    }

    var upgradeReason: MembershipUpgradeReason {
        switch self {
        case .sharedSpaces:
            return .numberOfSharedSpaces
        case .editors:
            return .numberOfSpaceEditors
        }
    }
}

struct SpaceLimitBannerView: View {

    let limitType: SpaceLimitBannerLimitType
    let onManageSpaces: (() -> Void)?
    let onUpgrade: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            titleView
            buttonsView
        }
        .padding(16)
        .background(gradientBackground)
        .cornerRadius(22)
    }

    private var titleView: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(limitType.titleText, style: .uxTitle2Semibold) + AnytypeText(" ", style: .uxTitle2Regular) +
            AnytypeText(limitType.subtitleText, style: .uxTitle2Regular)
        }
    }

    @ViewBuilder
    private var buttonsView: some View {
        HStack(spacing: 8) {
            if limitType.showManageButton {
                StandardButton(Loc.SpaceShare.manageSpaces, style: .secondaryMedium) {
                    onManageSpaces?()
                }
            }
            StandardButton(
                "\(MembershipConstants.membershipSymbol.rawValue) \(Loc.upgrade)",
                style: limitType.showManageButton ? .primaryMedium : .primaryLarge
            ) {
                onUpgrade()
            }
        }
    }

    private var gradientBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.Gradients.HeaderAlert.redStart,
                Color.Gradients.HeaderAlert.redEnd
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        SpaceLimitBannerView(
            limitType: .sharedSpaces(limit: 10),
            onManageSpaces: {},
            onUpgrade: {}
        )

        SpaceLimitBannerView(
            limitType: .editors(limit: 4),
            onManageSpaces: nil,
            onUpgrade: {}
        )
    }
    .padding()
    .background(Color.Background.primary)
}
