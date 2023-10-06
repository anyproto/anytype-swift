import Foundation
import SwiftUI

struct HomeBottomNavigationPanelView: View {
    
    let homePath: HomePath
    @StateObject var model: HomeBottomNavigationPanelViewModel
    
    var body: some View {
        buttons
//        .animation(.default, value: model.isEditState)
    }

    @ViewBuilder
    var buttons: some View {
        HStack(alignment: .center, spacing: 40) {
            
            if homeMode {
                Button {
                    model.onTapForward()
                } label: {
                    IconView(icon: .asset(.X32.Arrow.right))
                        .frame(width: 32, height: 32)
                }
                .id("transition1")
                .transition(.scale.combined(with: .opacity))
                .disabled(!homePath.hasForwardPath())
            } else {
                Button {
                    model.onTapBackward()
                } label: {
                    IconView(icon: .asset(.X32.Arrow.left))
                        .frame(width: 32, height: 32)
                }
                .id("transition2")
                .transition(.scale.combined(with: .opacity))
            }
            

            Button {
                model.onTapNewObject()
            } label: {
                IconView(icon: .asset( .X32.addNew))
                    .frame(width: 32, height: 32)
            }
            
            if homeMode {
                Button {
                    model.onTapSearch()
                } label: {
                    IconView(icon: .asset(.X32.search))
                        .frame(width: 32, height: 32)
                }
                .id("transition3")
                .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    model.onTapHome()
                } label: {
                    IconView(icon: .asset(.X32.dashboard))
                        .frame(width: 32, height: 32)
                }
                .id("transition4")
                .transition(.scale.combined(with: .opacity))
            }
            
            Button {
                model.onTapProfile()
            } label: {
                HStack {
                    IconView(icon: model.profileIcon)
                        .frame(width: 28, height: 28)
                }
                .frame(width: 32, height: 32)
            }
        }
        .foregroundStyle(.gray) // TODO: Use from design system
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.05))
        .background(.ultraThinMaterial)
        .cornerRadius(16, style: .continuous)
        .animation(.default, value: homeMode)
    }
    
    private var homeMode: Bool {
        return homePath.count == 0
    }
}
