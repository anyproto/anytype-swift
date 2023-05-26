import SwiftUI

struct ControlsExample: View {
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: "Controls")
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        makeLargeButtonVariants(title: "Primary Large", style: .primaryLarge)
                        makeLargeButtonVariants(title: "Secondary Large", style: .secondaryLarge)
                        makeLargeButtonVariants(title: "Destructive Large", style: .warningLarge)
                        
                        makeTwoByLineButtonVariants(title: "Primary Medium", style: .primaryMedium)
                        makeTwoByLineButtonVariants(title: "Secondary Medium", style: .secondaryMedium)
                        makeTwoByLineButtonVariants(title: "Destructive Medium", style: .warningMedium)
                    }
                    
                    Group {
                        makeTwoByLineButtonVariants(title: "Primary Small", style: .primarySmall)
                        makeTwoByLineButtonVariants(title: "Secondary Small", style: .secondarySmall)
                        makeTwoByLineButtonVariants(title: "Destructive Small", style: .warningSmall)
                        
                        makeTwoByLineButtonVariants(title: "Primary XSmall", style: .primaryXSmall)
                        makeTwoByLineButtonVariants(title: "Secondary XSmall", style: .secondaryXSmall)
                        makeTwoByLineButtonVariants(title: "Destructive XSmall", style: .warningXSmall)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.Background.primary.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func makeLargeButtonVariants(title: String, style: StandardButtonStyle) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            AnytypeText(title, style: .subheading, color: .Text.primary)
            StandardButton(
                "Normal",
                style: style,
                action: {}
            )
            StandardButton(
                "Pressed",
                style: style,
                holdPressState: true,
                action: {}
            )
            StandardButton(
                "Disabled",
                style: style,
                action: {}
            )
            .disabled(true)
            StandardButton(
                "In Progress",
                inProgress: true,
                style: style,
                action: {}
            )
            if style.config.infoTextFont.isNotNil {
                StandardButton(
                    "Counter",
                    info: "5",
                    style: style,
                    action: {}
                )
            }
        }
    }
    
    @ViewBuilder
    private func makeTwoByLineButtonVariants(title: String, style: StandardButtonStyle) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            AnytypeText(title, style: .subheading, color: .Text.primary)
            HStack {
                StandardButton(
                    "Normal",
                    style: style,
                    action: {}
                )
                StandardButton(
                    "Pressed",
                    style: style,
                    holdPressState: true,
                    action: {}
                )
            }
            HStack {
                StandardButton(
                    "Disabled",
                    style: style,
                    action: {}
                )
                .disabled(true)
                StandardButton(
                    "In Progress",
                    inProgress: true,
                    style: style,
                    action: {}
                )
            }
        }
    }
}

struct ControlsExample_Previews: PreviewProvider {
    static var previews: some View {
        ControlsExample()
    }
}
