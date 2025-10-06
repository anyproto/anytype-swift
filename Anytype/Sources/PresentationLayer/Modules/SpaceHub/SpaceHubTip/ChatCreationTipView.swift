import SwiftUI

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
        VStack(spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(48)
            carouselImages
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
    
    private func contentForPage(_ page: Int) -> PageContent {
        switch page {
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
            pageContent(with: ImageAsset.ChatCreationTip.step1, page: 1)
            pageContent(with: ImageAsset.ChatCreationTip.step2, page: 2)
            pageContent(with: ImageAsset.ChatCreationTip.step3, page: 3)
            pageContent(with: ImageAsset.ChatCreationTip.step4, page: 4)
        }
        .animation(.default, value: currentPage)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
    @ViewBuilder
    func pageContent(with image: ImageAsset, page: Int) -> some View {
        VStack(spacing: 0) {
            Image(asset: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 20)
            Spacer.fixedHeight(40)
            AnytypeText(contentForPage(page).title, style: .heading)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            Spacer.fixedHeight(9)
            AnytypeText(contentForPage(page).description, style: .uxBodyRegular)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
                .lineLimit(3, reservesSpace: true)
                .padding(.horizontal, 24)
        }
        .tag(page)
    }
}


#Preview {
    ChatCreationTipView()
}

private struct PageContent {
    let title: String
    let description: String
}
