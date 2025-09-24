import SwiftUI

@available(iOS 17.0, *)
struct ChatCreationTipView: View {
    @StateObject private var viewModel = ChatCreationTipViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage: Int = 1
    
    var body: some View {
        ZStack {
            Color.Background.secondary
                .ignoresSafeArea()
            content
        }
        .onAppear {
            AnytypeAnalytics.instance().logOnboardingTooltip(tooltip: .chats, step: currentPage)
        }
        .onDisappear() {
            viewModel.onDisappear()
        }
        .onChange(of: viewModel.dismiss) { _ in
            dismiss()
        }
        .onChange(of: currentPage) {
            AnytypeAnalytics.instance().logOnboardingTooltip(tooltip: .chats, step: $0)
        }
    }
    
    @ViewBuilder
    var content: some View {
        VStack {
            DragIndicator()
            Spacer.fixedHeight(48)
            carouselImages
            Spacer.fixedHeight(40)
            AnytypeText(pageContent.title, style: .heading)
                .foregroundColor(.Text.primary)
                .animation(.easeInOut(duration: 0.3), value: currentPage)
            Spacer.fixedHeight(9)
            AnytypeText(pageContent.description, style: .uxBodyRegular)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
                .lineLimit(3, reservesSpace: true)
                .padding(.horizontal, 24)
                .animation(.easeInOut(duration: 0.3), value: currentPage)
            Spacer.fixedHeight(34)
            pageIndicator
            Spacer.fixedHeight(16)
            StandardButton(
                currentPage == 4 ? Loc.letsTryIt : Loc.next,
                style: .secondaryLarge,
                action: {
                    if currentPage < 4 {
                        currentPage += 1
                    } else {
                        viewModel.tapClose()
                    }
                }
            )
            .padding(.horizontal, 24)
            .sheet(item: $viewModel.sharedUrl) { link in
                ActivityView(activityItems: [link])
            }
            Spacer.fixedHeight(20)
        }
    }
    
    private var pageContent: PageContent {
        switch currentPage {
        case 1:
            return PageContent(
                title: Loc.ChatTip.Step1.title,
                description: Loc.ChatTip.Step1.description
            )
        case 2:
            return PageContent(
                title: Loc.ChatTip.Step2.title,
                description: Loc.ChatTip.Step2.description
            )
        case 3:
            return PageContent(
                title: Loc.ChatTip.Step3.title,
                description: Loc.ChatTip.Step3.description
            )
        case 4:
            return PageContent(
                title: Loc.ChatTip.Step4.title,
                description: Loc.ChatTip.Step4.description
            )
        default:
            return PageContent(title: "", description: "")
        }
    }

    
    @ViewBuilder
    var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(1..<5, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.Additional.Indicator.selected : Color.Additional.Indicator.unselected)
                    .frame(width: 6, height: 6)
            }
        }
    }

    @ViewBuilder
    var carouselImages: some View {
        TabView(selection: $currentPage) {
            image(with: ImageAsset.ChatCreationTip.step1, tag: 1)
            image(with: ImageAsset.ChatCreationTip.step2, tag: 2)
            image(with: ImageAsset.ChatCreationTip.step3, tag: 3)
            image(with: ImageAsset.ChatCreationTip.step4, tag: 4)
        }
        .animation(.default, value: currentPage)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
    @ViewBuilder
    func image(with image: ImageAsset, tag: Int) -> some View {
        VStack {
            Image(asset: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Spacer.fixedHeight(36)
        }
        .tag(tag)
    }
}


// Fix Xcode warning
struct ChatCreationTipPreviewView: View {
    var body: some View {
        if #available(iOS 17.0, *) {
            ChatCreationTipView()
        } else {
            EmptyView()
        }
    }
}

#Preview {
    ChatCreationTipPreviewView()
}

private struct PageContent {
    let title: String
    let description: String
}
