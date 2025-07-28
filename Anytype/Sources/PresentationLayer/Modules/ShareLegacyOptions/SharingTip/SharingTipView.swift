import SwiftUI

@available(iOS 17.0, *)
struct SharingTipView: View {
    @StateObject private var viewModel = SharingTipViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.Background.secondary
                .ignoresSafeArea()
            gradient
                .ignoresSafeArea()
            content
            closeButton
        }
        .onAppear {
            setupAppearance()
            AnytypeAnalytics.instance().logOnboardingTooltip(tooltip: .sharingExtension)
        }
        .onDisappear() {
            viewModel.onDisappear()
        }
        .onChange(of: viewModel.dismiss) { _ in
            dismiss()
        }
    }
    
    @ViewBuilder
    var closeButton: some View {
        HStack {
            Spacer()
            VStack {
                Button {
                    viewModel.tapClose()
                } label: {
                    Image(asset: ImageAsset.X22.close)
                }
                Spacer()
            }.padding(.vertical, 12)
        }.padding(.horizontal, 12)
    }
    
    @ViewBuilder
    var content: some View {
        VStack {
            Spacer.fixedHeight(39)
            AnytypeText(Loc.Sharing.Tip.title, style: .heading)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(39)
            carouselImages
            Spacer.fixedHeight(32)
            HStack {
                VStack(alignment: .leading) {
                    ForEach(1...4, id: \.self) { i in
                        stepTextView(step: i)
                    }
                }
                Spacer()
            }
            .padding(.leading, 24)
            Spacer.fixedHeight(36)
            StandardButton(
                Loc.Sharing.Tip.Button.title,
                style: .secondaryLarge,
                action: { viewModel.tapShowShareMenu() }
            )
            .padding(.horizontal, 24)
            .sheet(item: $viewModel.sharedUrl) { link in
                ActivityView(activityItems: [link])
            }
            Spacer.fixedHeight(20)
        }
    }
    
    @ViewBuilder
    var gradient: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    .Gradients.white,
                    .Gradients.green
                ]
            ),
            startPoint: .init(x: 0.8, y: 0.8),
            endPoint: .bottomTrailing
        )
    }

    @ViewBuilder
    var carouselImages: some View {
        TabView {
            image(with: ImageAsset.SharingTip.step1, tag: 1)
            image(with: ImageAsset.SharingTip.step2, tag: 2)
            image(with: ImageAsset.SharingTip.step3, tag: 3)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
    
    @ViewBuilder
    func image(with image: ImageAsset, tag: Int) -> some View {
        VStack {
            Image(asset: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .tag(tag)
            Spacer.fixedHeight(36)
        }
    }
    
    @ViewBuilder
    private func stepTextView(step number: Int) -> some View {
        if let tipStep = SharingTipStep(rawValue: number) {
            HStack(spacing: 8) {
                AnytypeText("\(number).  \(tipStep.title)", style: .uxBodyRegular)
                    .foregroundColor(.Text.primary)
                tipStep.image
            }
        } else {
            EmptyView()
        }
    }
    
    private func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.Additional.Indicator.selected
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.Additional.Indicator.unselected
    }
}

private enum SharingTipStep: Int {
    case first = 1
    case second
    case third
    
    var title: String {
        switch self {
        case .first:
            return Loc.Sharing.Tip.Steps._1
        case .second:
            return Loc.Sharing.Tip.Steps._2
        case .third:
            return Loc.Sharing.Tip.Steps._3
        }
    }
    
    var image: Image {
        switch self {
        case .first:
            return Image(asset: ImageAsset.X19.share)
        case .second:
            return Image(asset: ImageAsset.X19.more)
        case .third:
            return Image(asset: ImageAsset.X19.plus)
        }
    }
}

// Fix Xcode warning
struct SharingTipPreviewView: View {
    var body: some View {
        if #available(iOS 17.0, *) {
            SharingTipView()
        } else {
            EmptyView()
        }
    }
}

#Preview {
    SharingTipPreviewView()
}

