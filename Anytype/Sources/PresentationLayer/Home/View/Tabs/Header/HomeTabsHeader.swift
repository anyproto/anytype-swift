import SwiftUI
import SwiftUIVisualEffects

struct HomeTabsHeader: View {
    @EnvironmentObject var model: HomeViewModel
    @Binding var tabSelection: HomeTabsView.Tab
    var onTabSelection: () -> ()
    
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
        HStack(spacing: 20) {
            tabButton(text: "Favorites".localized, tab: .favourites)
            tabButton(text: "History".localized, tab: .history) {
                if tabSelection == .history { onTabSelection() } // reload data on button tap
            }
            tabButton(text: "Bin".localized, tab: .bin) {
                if tabSelection == .bin { onTabSelection() } // reload data on button tap
            }
            Spacer()
        }
    }
    
    private func tabButton(text: String, tab: HomeTabsView.Tab, action: (() -> ())? = nil) -> some View {
        Button(
            action: {
                withAnimation(.spring()) {
                    tabSelection = tab
                    action?()
                }
            }
        ) {
            HomeTabsHeaderText(text: text, isSelected: tabSelection == tab)
        }
    }
}
