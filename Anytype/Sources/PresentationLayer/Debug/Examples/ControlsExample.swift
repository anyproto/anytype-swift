import SwiftUI

struct ControlsExample: View {
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: "Controls")
            ScrollView {
                VStack(alignment: .leading) {
                    Group {
                        makeLargeButtonVariants(title: "Primary Large - Light", style: .primaryLarge).colorScheme(.light)
                        makeLargeButtonVariants(title: "Primary Large - Dark", style: .primaryLarge).colorScheme(.dark)
                        
                        makeLargeButtonVariants(title: "Secondary Large - Light", style: .secondaryLarge).colorScheme(.light)
                        makeLargeButtonVariants(title: "Secondary Large - Dark", style: .secondaryLarge).colorScheme(.dark)
                        
                        makeLargeButtonVariants(title: "Destructive Large - Light", style: .warningLarge).colorScheme(.light)
                        makeLargeButtonVariants(title: "Destructive Large - Dark", style: .warningLarge).colorScheme(.dark)
                    }
                    
                    Group {
                        makeTwoByLineButtonVariants(title: "Primary Medium - Light", style: .primaryMedium).colorScheme(.light)
                        makeTwoByLineButtonVariants(title: "Primary Medium - Dark", style: .primaryMedium).colorScheme(.dark)
                        
                        makeTwoByLineButtonVariants(title: "Secondary Medium - Light", style: .secondaryMedium).colorScheme(.light)
                        makeTwoByLineButtonVariants(title: "Secondary Medium - Dark", style: .secondaryMedium).colorScheme(.dark)
                        
                        makeTwoByLineButtonVariants(title: "Destructive Medium - Light", style: .warningMedium).colorScheme(.light)
                        makeTwoByLineButtonVariants(title: "Destructive Medium - Dark", style: .warningMedium).colorScheme(.dark)
                    }
                    
                    Group {
                        makeTwoByLineButtonVariants(title: "Primary Small - Light", style: .primarySmall).colorScheme(.light)
                        makeTwoByLineButtonVariants(title: "Primary Small - Dark", style: .primarySmall).colorScheme(.dark)
                        
                        makeTwoByLineButtonVariants(title: "Secondary Small - Light", style: .secondarySmall).colorScheme(.light)
                        makeTwoByLineButtonVariants(title: "Secondary Small - Dark", style: .secondarySmall).colorScheme(.dark)
                        
                        makeTwoByLineButtonVariants(title: "Destructive Small - Light", style: .warningSmall).colorScheme(.light)
                        makeTwoByLineButtonVariants(title: "Destructive Small - Dark", style: .warningSmall).colorScheme(.dark)
                    }
                    
                    Group {
                        makeTwoByLineButtonVariants(title: "Primary XSmall - Light", style: .primaryXSmall).colorScheme(.light)
                        makeTwoByLineButtonVariants(title: "Primary XSmall - Dark", style: .primaryXSmall).colorScheme(.dark)
                        
                        makeTwoByLineButtonVariants(title: "Secondary XSmall - Light", style: .secondaryXSmall).colorScheme(.light)
                        makeTwoByLineButtonVariants(title: "Secondary XSmall - Dark", style: .secondaryXSmall).colorScheme(.dark)
                        
                        makeTwoByLineButtonVariants(title: "Destructive XSmall - Light", style: .warningXSmall).colorScheme(.light)
                        makeTwoByLineButtonVariants(title: "Destructive XSmall - Dark", style: .warningXSmall).colorScheme(.dark)
                        
                        makeTwoByLineButtonVariants(title: "Transparent XSmall - Light", style: .transparentXSmall).colorScheme(.light)
                        makeTwoByLineButtonVariants(title: "Transparent XSmall - Dark", style: .transparentXSmall).colorScheme(.dark)
                    }
                    
                    Group {
                        makeComposeButtons(title: "Composite buttons")
                            .colorScheme(.light)
                        makeComposeButtons(title: "Composite buttons")
                            .colorScheme(.dark)
                    }
                }
            }
        }
        .background(Color.Background.primary.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func makeLargeButtonVariants(title: String, style: StandardButtonStyle) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            AnytypeText(title, style: .subheading)
                .foregroundColor(.Text.primary)
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
        .padding(16)
        .background(Color.Background.primary)
    }
    
    @ViewBuilder
    private func makeTwoByLineButtonVariants(title: String, style: StandardButtonStyle) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            AnytypeText(title, style: .subheading)
                .foregroundColor(.Text.primary)
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
        .padding(16)
        .background(Color.Background.primary)
    }
    
    @ViewBuilder
    private func makeComposeButtons(title: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            AnytypeText(title, style: .subheading)
                .foregroundColor(.Text.primary)
            HStack(spacing: .zero) {
                StandardButton(
                    Loc.new,
                    style: .primaryXSmall,
                    corners: [.topLeft, .bottomLeft]
                ) {
                    UISelectionFeedbackGenerator().selectionChanged()
                }
                Rectangle()
                    .fill(Color.Shape.primary)
                    .frame(width: 1, height: 28)
                StandardButton(.image(.X18.listArrow), style: .primaryXSmall, corners: [.topRight, .bottomRight]) {
                    UISelectionFeedbackGenerator().selectionChanged()
                }
            }
        }
        .padding(16)
        .background(Color.Background.primary)
    }
}

struct ControlsExample_Previews: PreviewProvider {
    static var previews: some View {
        ControlsExample()
    }
}
