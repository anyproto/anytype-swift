import SwiftUI
import SwiftUIVisualEffects
import AnytypeCore

struct HomeTabsHeader: View {
    @EnvironmentObject var model: HomeViewModel
    @Binding var tabSelection: HomeTabsView.Tab
    
    var body: some View {
        // Scroll view hack, vibrancy effect do not work without it
        ScrollView([]) {
            Group {
                if model.isSelectionMode {
                    HomeTabsSelectionHeader()
                        .padding(.horizontal, 20)
                } else {
                    defaultTabHeader
                        .padding(.leading, 20)
                }
            }
            .frame(height: 72, alignment: .center)
            .background(BlurEffect())
            .blurEffectStyle(UIBlurEffect.Style.systemMaterial)
        }
        .frame(height: 72, alignment: .center)
    }
    
    private var defaultTabHeader: some View {
        HStack(spacing: 0) {
            tabButton(text: "Favorites".localized, tab: .favourites)
            Spacer().frame(maxWidth: 15)
            tabButton(text: "History".localized, tab: .history)
            Spacer().frame(maxWidth: 15)
            if FeatureFlags.sets {
                tabButton(text: "Sets".localized, tab: .sets)
                Spacer().frame(maxWidth: 15)
            }
            if AccountConfigurationProvider.shared.config.enableSpaces {
                tabButton(text: "Shared".localized, tab: .shared)
                Spacer().frame(maxWidth: 15)
            }
            tabButton(text: "Bin".localized, tab: .bin)
            Spacer()
        }
    }
    
    private func tabButton(text: String, tab: HomeTabsView.Tab) -> some View {
        Button(
            action: {
                withAnimation(.spring()) {
                    tabSelection = tab
                }
            }
        ) {
            HomeTabsHeaderText(text: text, isSelected: tabSelection == tab)
                .frame(minWidth: 40)
                .contentShape(Rectangle())
        }
    }
}
