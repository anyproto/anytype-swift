import Foundation
import SwiftUI

struct HomeBottomNavigationPanelView: View {
    
    let countItems: Int
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
                    Image(asset: .X32.Arrow.right)
                }
                .id("transition1")
                .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    model.onTapBackward()
                } label: {
                    Image(asset: .X32.Arrow.left)
                }
                .id("transition2")
                .transition(.scale.combined(with: .opacity))
            }
            

            Button {
                model.onTapNewObject()
            } label: {
                Image(asset: .X32.addNew)
            }
            
            if homeMode {
                Button {
                    model.onTapSearch()
                } label: {
                    Image(asset: .X32.search)
                }
                .id("transition3")
                .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    model.onTapHome()
                } label: {
                    Image(asset: .X32.dashboard)
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
        return countItems == 0
    }
}
