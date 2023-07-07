import SwiftUI

struct CreatingSoulView: View {
    
    @ObservedObject var model: CreatingSoulViewModel
    @State private var showSpaceTitle = false
    
    var body: some View {
        GeometryReader { geo in
            content(width: geo.size.width)
        }
        .padding(.horizontal, UIDevice.isPad ? 75 : 0)
        .task {
            try? await Task.sleep(seconds: 0.5)
            showSpaceTitle.toggle()
            model.setupSubscription()
        }
    }
    
    private func content(width: CGFloat) -> some View {
        VStack(alignment: .center, spacing: 0) {
            AnytypeText(
                model.showSpaceIcon ? Loc.Auth.JoinFlow.Setting.Space.title : Loc.Auth.JoinFlow.Creating.Soul.title,
                style: .uxTitle1Semibold,
                color: .Text.primary
            )
            .opacity(showSpaceTitle ? 0.9 : 0)
            
            Spacer.fixedHeight(64)

            personalContent(width: width)
            
        }
        .frame(width: width)
        .onAppear {
            model.onAppear()
        }
    }
    
    private func personalContent(width: CGFloat) -> some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Spacer.fixedHeight(Constants.imageDimension / 2)
                Rectangle().foregroundColor(.Auth.body)
                    .frame(
                        width: model.showSpaceIcon ? width / Constants.scaleFactor : 0,
                        height: 2
                    )
                    .opacity(model.showSpaceIcon ? 1 : 0)
                    .padding(.trailing, Constants.imageDimension / 2)
            }
            if model.showProfileIcon {
                space
                    .offset(x: model.showSpaceIcon ? width / (Constants.scaleFactor * 2) : 0)
                    .opacity(model.showSpaceIcon ? 1 : 0)
                soul
                    .offset(x: model.showSpaceIcon ? -width / (Constants.scaleFactor * 2) : 0)
            }
        }
    }
    
    private var soul: some View {
        VStack(spacing: 8) {
            SwiftUIObjectIconImageViewWithPlaceholder(iconImage: model.profileIcon, usecase: .dashboardSearch)
                .frame(width: Constants.imageDimension, height: Constants.imageDimension)
            AnytypeText(model.state.soul, style: .previewTitle2Medium, color: .Text.primary)
                .lineLimit(1)
        }
        .frame(width: Constants.itemWidth)
    }
    
    private var space: some View {
        VStack(spacing: 8) {
            SwiftUIObjectIconImageViewWithPlaceholder(iconImage: model.spaceIcon, usecase: .dashboardSearch)
                .frame(width: Constants.imageDimension, height: Constants.imageDimension)
            AnytypeText(Loc.Auth.JoinFlow.Personal.Space.title, style: .previewTitle2Medium, color: .Text.primary)
                .multilineTextAlignment(.center)
        }
        .frame(width: Constants.itemWidth)
    }
}

private extension CreatingSoulView {
    enum Constants {
        static let imageDimension: CGFloat = 48
        static let scaleFactor: CGFloat = 2
        static let itemWidth: CGFloat = 110
    }
}


struct CreatingSoulView_Previews : PreviewProvider {
    static var previews: some View {
        CreatingSoulView(
            model: CreatingSoulViewModel(
                state: JoinFlowState(),
                output: nil,
                accountManager: DI.preview.serviceLocator.accountManager(),
                subscriptionService: DI.preview.serviceLocator.singleObjectSubscriptionService()
            )
        )
    }
}
