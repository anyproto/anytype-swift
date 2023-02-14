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
                        .padding(.leading, 10)
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
            tabButton(text: Loc.favorites, tab: .favourites)
            tabButton(text: Loc.recent, tab: .recent)
            tabButton(text: Loc.sets, tab: .sets)
            if model.enableSpace {
                tabButton(text: Loc.shared, tab: .shared)
            }
            tabButton(text: Loc.bin, tab: .bin)
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
                .padding(.horizontal, 10)
                .padding(.vertical, 12)
                
        }
    }
}
