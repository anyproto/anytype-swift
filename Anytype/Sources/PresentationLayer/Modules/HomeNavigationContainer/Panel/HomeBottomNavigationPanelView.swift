import Foundation
import SwiftUI

struct HomeBottomNavigationPanelView: View {
    
    let homePath: HomePath
    @StateObject var model: HomeBottomNavigationPanelViewModel
    
    var body: some View {
        buttons
    }

    @ViewBuilder
    var buttons: some View {
        HStack(alignment: .center, spacing: 40) {
            if homeMode {
                Button {
                    model.onTapForward()
                } label: {
                    Image(asset: .X32.Arrow.right)
                        .foregroundColor(.Navigation.buttonActive)
                }
                .transition(.identity)
                .disabled(!homePath.hasForwardPath())
            } else {
                Button {
                    model.onTapBackward()
                } label: {
                    Image(asset: .X32.Arrow.left)
                        .foregroundColor(.Navigation.buttonActive)
                }
                .transition(.identity)
            }
            
            Button {
                model.onTapNewObject()
            } label: {
                Image(asset: .X32.addNew)
                    .foregroundColor(.Navigation.buttonActive)
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.3)
                    .onEnded { _ in
                        model.onTapCreateObjectWithType()
                    }
            )
            .if(homeMode) {
                $0.popoverHomeCreateObjectTip()
            }
            
            if homeMode {
                Button {
                    model.onTapSearch()
                } label: {
                    Image(asset: .X32.search)
                        .foregroundColor(.Navigation.buttonActive)
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    model.onTapHome()
                } label: {
                    Image(asset: .X32.dashboard)
                        .foregroundColor(.Navigation.buttonActive)
                }
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
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.Navigation.background)
        .background(.ultraThinMaterial)
        .cornerRadius(16, style: .continuous)
        .padding(.vertical, 10)
        .animation(.default, value: homeMode)
    }
    
    private var homeMode: Bool {
        return homePath.count <= 1
    }
}
