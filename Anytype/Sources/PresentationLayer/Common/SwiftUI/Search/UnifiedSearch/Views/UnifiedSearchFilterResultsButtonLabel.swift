import SwiftUI

struct UnifiedSearchFilterResultsButtonLabel: View {

    let showsOnboarding: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            if showsOnboarding {
                AnytypeText(Loc.UnifiedSearch.Onboarding.useAsFilter, style: .uxCalloutMedium)
                    .foregroundStyle(foregroundColor)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .offset(y: -2)
            }

            Image(asset: .X18.search)
        }
        .foregroundStyle(foregroundColor)
        .frame(minWidth: 44, minHeight: 44, alignment: .trailing)
        .fixTappableArea()
    }

    private var foregroundColor: Color {
        showsOnboarding ? Color.Control.accent80 : Color.Control.primary
    }
}
