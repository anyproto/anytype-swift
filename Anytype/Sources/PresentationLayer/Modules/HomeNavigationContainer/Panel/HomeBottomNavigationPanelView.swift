import Foundation
import SwiftUI
import AnytypeCore
import Services

struct HomeBottomNavigationPanelView: View {
    
    let homePath: HomePath
    let info: AccountInfo
    weak var output: (any HomeBottomNavigationPanelModuleOutput)?
    
    var body: some View {
        HomeBottomNavigationPanelViewInternal(homePath: homePath, info: info, output: output)
            .id(info.accountSpaceId)
    }
}

private struct HomeBottomNavigationPanelViewInternal: View {
    
    let homePath: HomePath
    @StateObject private var model: HomeBottomNavigationPanelViewModel
    
    init(homePath: HomePath, info: AccountInfo, output: (any HomeBottomNavigationPanelModuleOutput)?) {
        self.homePath = homePath
        self._model = StateObject(wrappedValue: HomeBottomNavigationPanelViewModel(info: info, output: output))
    }
    
    var body: some View {
        buttons
    }

    @ViewBuilder
    var buttons: some View {
        HStack(alignment: .center, spacing: 40) {
            navigation
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(progressView)
        .background(Color.Navigation.background)
        .background(.ultraThinMaterial)
        .cornerRadius(16, style: .continuous)
        .overlay {
            if #available(iOS 17.0, *) {
                HomeTipView()
            }
        }
        .overlay {
            if #available(iOS 17.0, *) {
                SpaceSwitcherTipView()
            }
        }
        .padding(.vertical, 10)
        .if(FeatureFlags.homeTestSwipeGeature) { view in
            view.gesture(
                DragGesture(minimumDistance: 100)
                    .onEnded { value in
                        if value.translation.width > 150 {
                            model.onTapBackward()
                        } else if value.translation.width < -150 {
                            model.onTapForward()
                        }
                    }
            )
        }
        .animation(.default, value: homeMode)
        .task {
            await model.onAppear()
        }
    }
    
    @ViewBuilder
    private var navigation: some View {
        Image(asset: .X32.Island.back)
            .onTapGesture {
                model.onTapBackward()
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.3)
                    .onEnded { _ in
                        if #available(iOS 17.0, *) {
                            SpaceSwitcherTip.openedSpaceSwitcher = true
                        }
                        model.onTapProfile()
                    }
            )
        
        Button {
            model.onTapSearch()
        } label: {
            Image(asset: .X32.Island.search)
        }
        
        if model.canCreateObject {
            Image(asset: .X32.Island.add)
                .onTapGesture {
                    model.onTapNewObject()
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.3)
                        .onEnded { _ in
                            model.onPlusButtonLongtap()
                        }
                )
        }
    }
    
    @ViewBuilder
    private var navigationButton: some View {
        Button {
            if homeMode {
                model.onTapForward()
            } else {
                model.onTapBackward()
            }
        } label: {
            Image(asset: .X32.Arrow.left)
                .foregroundColor(navigationButtonDisabled ? .Navigation.buttonInactive : .Navigation.buttonActive)
        }
        .transition(.identity)
        .disabled(navigationButtonDisabled)
    }
    
    private var navigationButtonDisabled: Bool {
        homeMode && !homePath.hasForwardPath()
    }
    
    private var homeMode: Bool {
        return homePath.count <= 1
    }
    
    @ViewBuilder
    private var progressView: some View {
        if let progress = model.progress {
            GeometryReader { reader in
                Color.VeryLight.amber
                    .cornerRadius(2)
                    .frame(width: max(reader.size.width * progress, 30), alignment: .leading)
                    .animation(.linear, value: progress)
            }
            .transition(.opacity)
        }
    }
}
