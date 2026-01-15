import SwiftUI

enum NavigationHeaderConstants {
    static let height: CGFloat = 44
    static let buttonSize: CGFloat = 44
}

enum NavigationHeaderButtonType: Hashable {
    case back
    case dismiss
    case none
}

struct NavigationHeader<LeftContent: View, TitleContent: View, RightContent: View>: View {

    @ViewBuilder let leftContent: LeftContent
    @ViewBuilder let titleContent: TitleContent
    @ViewBuilder let rightContent: RightContent
    let isTitleInteractive: Bool
    let enableBackgroundBlur: Bool

    @State private var leftWidth: CGFloat = 0
    @State private var rightWidth: CGFloat = 0

    @Namespace private var glassNamespace
    @Environment(\.widgetsAnimationNamespace) private var widgetsNamespace

    init(
        isTitleInteractive: Bool = false,
        enableBackgroundBlur: Bool = true,
        @ViewBuilder leftContent: () -> LeftContent,
        @ViewBuilder titleContent: () -> TitleContent,
        @ViewBuilder rightContent: () -> RightContent
    ) {
        self.isTitleInteractive = isTitleInteractive
        self.enableBackgroundBlur = enableBackgroundBlur
        self.leftContent = leftContent()
        self.titleContent = titleContent()
        self.rightContent = rightContent()
    }

    var body: some View {
        GlassEffectContainerIOS26(spacing: 12) {
            ZStack {
                titleView
                    .frame(maxWidth: .infinity)
                    .padding(.leading, leftWidth + 8)
                    .padding(.trailing, rightWidth + 8)

                HStack {
                    leftContent
                        .glassEffectIDIOS26("leftContent", in: glassNamespace)
                        .readSize { leftWidth = $0.width }
                    Spacer()
                    rightContent
                        .glassEffectIDIOS26("rightContent", in: glassNamespace)
                        .readSize { rightWidth = $0.width }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .frame(height: NavigationHeaderConstants.height)
        .background {
            if enableBackgroundBlur {
                HomeBlurEffectView(direction: .topToBottom)
                    .ignoresSafeArea()
            }
        }
    }

    @ViewBuilder
    private var titleView: some View {
        if isTitleInteractive {
            titleContent
                .matchedTransitionSourceIOS26(id: "widgetsOverlay", in: widgetsNamespace)
                .glassEffectInteractiveIOS26(in: Capsule())
                .glassEffectIDIOS26("titlePill", in: glassNamespace)
        } else {
            titleContent
        }
    }
}

// MARK: - Back/Dismiss Button Convenience

extension NavigationHeader where LeftContent == NavigationHeaderLeftButton {
    init(
        navigationButtonType: NavigationHeaderButtonType,
        isTitleInteractive: Bool = false,
        @ViewBuilder titleContent: () -> TitleContent,
        @ViewBuilder rightContent: () -> RightContent
    ) {
        self.isTitleInteractive = isTitleInteractive
        self.enableBackgroundBlur = true
        self.leftContent = NavigationHeaderLeftButton(type: navigationButtonType)
        self.titleContent = titleContent()
        self.rightContent = rightContent()
    }
}

// MARK: - Simple Title Convenience (Non-Interactive)

extension NavigationHeader where LeftContent == NavigationHeaderLeftButton, TitleContent == NavigationHeaderTitle {
    init(
        title: String,
        navigationButtonType: NavigationHeaderButtonType = .back,
        @ViewBuilder rightContent: () -> RightContent
    ) {
        self.isTitleInteractive = false
        self.enableBackgroundBlur = true
        self.leftContent = NavigationHeaderLeftButton(type: navigationButtonType)
        self.titleContent = NavigationHeaderTitle(title: title)
        self.rightContent = rightContent()
    }
}

// MARK: - Simple Title, No Right Content

extension NavigationHeader where LeftContent == NavigationHeaderLeftButton, TitleContent == NavigationHeaderTitle, RightContent == EmptyView {
    init(
        title: String,
        navigationButtonType: NavigationHeaderButtonType = .back
    ) {
        self.isTitleInteractive = false
        self.enableBackgroundBlur = true
        self.leftContent = NavigationHeaderLeftButton(type: navigationButtonType)
        self.titleContent = NavigationHeaderTitle(title: title)
        self.rightContent = EmptyView()
    }
}

// MARK: - Interactive Title Convenience

extension NavigationHeader where LeftContent == NavigationHeaderLeftButton, TitleContent == NavigationHeaderInteractiveTitlePill {
    init(
        title: String,
        icon: Icon? = nil,
        onTitleTap: @escaping () -> Void,
        navigationButtonType: NavigationHeaderButtonType = .back,
        @ViewBuilder rightContent: () -> RightContent
    ) {
        self.isTitleInteractive = true
        self.enableBackgroundBlur = true
        self.leftContent = NavigationHeaderLeftButton(type: navigationButtonType)
        self.titleContent = NavigationHeaderInteractiveTitlePill(title: title, icon: icon, onTap: onTitleTap)
        self.rightContent = rightContent()
    }
}

// MARK: - Custom Title, No Right Content

extension NavigationHeader where LeftContent == NavigationHeaderLeftButton, RightContent == EmptyView {
    init(
        navigationButtonType: NavigationHeaderButtonType,
        isTitleInteractive: Bool = false,
        @ViewBuilder titleContent: () -> TitleContent
    ) {
        self.isTitleInteractive = isTitleInteractive
        self.enableBackgroundBlur = true
        self.leftContent = NavigationHeaderLeftButton(type: navigationButtonType)
        self.titleContent = titleContent()
        self.rightContent = EmptyView()
    }
}

// MARK: - Interactive Title, No Right Content

extension NavigationHeader where LeftContent == NavigationHeaderLeftButton, TitleContent == NavigationHeaderInteractiveTitlePill, RightContent == EmptyView {
    init(
        title: String,
        icon: Icon? = nil,
        onTitleTap: @escaping () -> Void,
        navigationButtonType: NavigationHeaderButtonType = .back
    ) {
        self.isTitleInteractive = true
        self.enableBackgroundBlur = true
        self.leftContent = NavigationHeaderLeftButton(type: navigationButtonType)
        self.titleContent = NavigationHeaderInteractiveTitlePill(title: title, icon: icon, onTap: onTitleTap)
        self.rightContent = EmptyView()
    }
}
