import SwiftUI

struct SpaceHubTipView: View {
    @StateObject private var model = SpaceHubTipViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var tabIndex: Int = 1
    
    var body: some View {
        ZStack {
            Color.Background.primary
                .ignoresSafeArea()
            content
        }
        .onAppear {
            model.onAppear()
            setupAppearance()
        }
        .onDisappear() {
            model.onDisappear()
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
        .onChange(of: tabIndex) {
            model.onStepChanged(step: $0)
        }
    }
    
    var content: some View {
        VStack {
            DragIndicator()
            Spacer.fixedHeight(22)
            AnytypeText(titleText, style: .heading)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Spacer.fixedHeight(42)
            carouselImages
            Spacer.fixedHeight(20)
            AnytypeText(text, style: .uxBodyRegular)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            Spacer.fixedHeight(30)
            button
            Spacer.fixedHeight(20)
        }
        .padding(.horizontal, 24)
    }
    
    var titleText: String {
        if tabIndex == 3 {
            Loc.SpaceHub.Tip.title3
        } else if tabIndex == 2 {
            Loc.SpaceHub.Tip.title2
        } else {
            Loc.SpaceHub.Tip.title1
        }
    }
    
    var text: String {
        if tabIndex == 3 {
            Loc.SpaceHub.Tip.text3
        } else if tabIndex == 2 {
            Loc.SpaceHub.Tip.text2
        } else {
            Loc.SpaceHub.Tip.text1
        }
    }
    
    var button: some View {
        if tabIndex == 3 {
            StandardButton(
                Loc.letsGo,
                style: .secondaryLarge,
                action: { model.tapClose() }
            )
            .padding(.horizontal, 24)
        } else {
            StandardButton(
                Loc.next,
                style: .secondaryLarge,
                action: { tabIndex += 1 }
            )
            .padding(.horizontal, 24)
        }
    }

    var carouselImages: some View {
        TabView(selection: $tabIndex) {
            image(with: ImageAsset.SpaceHubTip.vaultImmersive, tag: 1)
                .overlay { imageGradient }
            
            image(with: ImageAsset.SpaceHubTip.vaultMove, tag: 2)
            
            image(
                with: colorScheme == .dark ? ImageAsset.SpaceHubTip.backgroundsDark : ImageAsset.SpaceHubTip.backgroundsLight,
                tag: 3
            ).overlay {
                imageGradient
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
    
    func image(with image: ImageAsset, tag: Int) -> some View {
        VStack {
            Image(asset: image)
                .resizable()
                .scaledToFit()
            Spacer.fixedHeight(40)
        }
        .tag(tag)
    }
    
    var imageGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    .clear,
                    colorScheme == .dark ? .black : .white
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
        
    private func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.Additional.Indicator.selected
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.Additional.Indicator.unselected
    }
}

// Fix Xcode warning
struct SpaceHubTipPreviewView: View {
    var body: some View {
        if #available(iOS 17.0, *) {
            SpaceHubTipView()
        } else {
            EmptyView()
        }
    }
}

#Preview {
    SpaceHubTipPreviewView()
}

