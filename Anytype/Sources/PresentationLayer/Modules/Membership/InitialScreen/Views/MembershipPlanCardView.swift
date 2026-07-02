import SwiftUI
import Services


// Shared card for both the current plan and the recommended upgrade. Neutral
// container (not a tier gradient) with the tier name, colored tier mark and a
// CTA pill. Tapping anywhere on the card opens the tier's full-screen details;
// the CTA pill is a visual affordance, not a separate tap target.
struct MembershipPlanCardView: View {
    enum CTAStyle {
        case upgrade
        case current
    }

    let tier: MembershipTier
    let ctaText: String
    let ctaStyle: CTAStyle
    let onTap: () -> ()

    var body: some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 0) {
                        AnytypeText(tier.name, style: .heading)
                            .foregroundStyle(Color.Text.primary)
                        Spacer.fixedHeight(12)
                        features
                    }
                    Spacer(minLength: 0)
                    Image(asset: tier.smallIcon)
                        .resizable()
                        .frame(width: 64, height: 64)
                }
                Spacer.fixedHeight(16)
                ctaPill
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.Shape.transparentTertiary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var features: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(tier.features, id: \.self) { feature in
                MembershipFeatureRow(text: feature)
            }
        }
    }

    private var ctaPill: some View {
        AnytypeText(ctaText, style: .button1Medium)
            .foregroundStyle(ctaStyle == .upgrade ? Color.Text.white : Color.Text.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(ctaBackground, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var ctaBackground: Color {
        switch ctaStyle {
        case .upgrade:
            Color.Control.accent100
        case .current:
            Color.Shape.transparentTertiary
        }
    }
}


// Single feature line: thin Figma check (14×14, Text.primary stroke) + label.
private struct MembershipFeatureRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            MembershipFeatureCheckmark()
                .stroke(Color.Text.primary, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                .frame(width: 14, height: 14)
                .padding(.top, 2)
            AnytypeText(text, style: .caption1Regular)
                .foregroundStyle(Color.Text.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}


private struct MembershipFeatureCheckmark: Shape {
    func path(in rect: CGRect) -> Path {
        let scaleX = rect.width / 14
        let scaleY = rect.height / 14
        var path = Path()
        path.move(to: CGPoint(x: 3 * scaleX, y: 7 * scaleY))
        path.addLine(to: CGPoint(x: 6.2 * scaleX, y: 10.5 * scaleY))
        path.addLine(to: CGPoint(x: 11 * scaleX, y: 3.5 * scaleY))
        return path
    }
}

#Preview {
    VStack(spacing: 12) {
        MembershipPlanCardView(tier: .mockStarter, ctaText: Loc.Membership.currentPlan, ctaStyle: .current, onTap: {})
        MembershipPlanCardView(tier: .mockCoCreator, ctaText: Loc.upgrade, ctaStyle: .upgrade, onTap: {})
    }
    .padding(16)
}
