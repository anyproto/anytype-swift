import SwiftUI

struct SpaceShareTipView: View {
    @StateObject private var model = SpaceShareTipViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var tabIndex: Int = 1
    
    var body: some View {
        ZStack {
            gradient
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
    }
    
    @ViewBuilder
    var content: some View {
        VStack {
            Spacer.fixedHeight(40)
            AnytypeText(Loc.SpaceShare.Tip.title, style: .heading)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(38)
            carouselImages
            Spacer.fixedHeight(32)
            HStack {
                VStack(alignment: .leading) {
                    AnytypeText("\(1). \(Loc.SpaceShare.Tip.Steps._1)", style: .uxBodyRegular)
                        .foregroundColor(.Text.primary)
                    AnytypeText("\(2). \(Loc.SpaceShare.Tip.Steps._2)", style: .uxBodyRegular)
                        .foregroundColor(.Text.primary)
                    AnytypeText("\(3). \(Loc.SpaceShare.Tip.Steps._3)", style: .uxBodyRegular)
                        .foregroundColor(.Text.primary)
                }
                Spacer()
            }.padding(.horizontal, 24)
            Spacer.fixedHeight(30)
            if tabIndex == 3 {
                StandardButton(
                    Loc.done,
                    style: .secondaryLarge,
                    action: { model.tapClose() }
                )
                .padding(.horizontal, 24)
            } else {
                StandardButton(
                    Loc.next,
                    style: .secondaryLarge,
                    action: {
                        withAnimation {
                            tabIndex += 1
                        }
                    }
                )
                .padding(.horizontal, 24)
            }
            Spacer.fixedHeight(20)
        }
    }
    
    @ViewBuilder
    var gradient: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color.Text.labelInversion,
                    Color.Additional.gradient
                ]
            ),
            startPoint: .init(x: 0.8, y: 0.8),
            endPoint: .bottomTrailing
        )
    }

    @ViewBuilder
    var carouselImages: some View {
        TabView(selection: $tabIndex) {
            image(with: ImageAsset.SpaceShareTip.step1, tag: 1)
            image(with: ImageAsset.SpaceShareTip.step2, tag: 2)
            image(with: ImageAsset.SpaceShareTip.step3, tag: 3)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
    
    @ViewBuilder
    func image(with image: ImageAsset, tag: Int) -> some View {
        VStack {
            Image(asset: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Spacer.fixedHeight(40)
        }
        .tag(tag)
    }
        
    private func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.Additional.Indicator.selected
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.Additional.Indicator.unselected
    }
}

// Fix Xcode warning
struct SpaceShareTipPreviewView: View {
    var body: some View {
        if #available(iOS 17.0, *) {
            SpaceShareTipView()
        } else {
            EmptyView()
        }
    }
}

#Preview {
    SpaceShareTipPreviewView()
}

