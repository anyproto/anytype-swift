import SwiftUI

struct CreatingSoulView: View {
    
    @ObservedObject var model: CreatingSoulViewModel
    
    var body: some View {
        GeometryReader { geo in
            content(width: geo.size.width)
        }
    }
    
    private func content(width: CGFloat) -> some View {
        VStack(alignment: .center, spacing: 0) {
            AnytypeText(
                model.showSpace ? Loc.Auth.JoinFlow.Setting.Space.title : Loc.Auth.JoinFlow.Creating.Soul.title,
                style: .uxTitle1Semibold,
                color: .Text.primary
            )
            .opacity(0.9)
            .animation(.easeInOut, value: model.showSpace)
            
            Spacer.fixedHeight(64)

            personalContent(width: width)
            
        }
        .frame(width: width)
    }
    
    private func personalContent(width: CGFloat) -> some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Spacer.fixedHeight(24)
                Rectangle().foregroundColor(.Auth.inputText)
                    .frame(
                        width: model.showSpace ? width / 2 : 0,
                        height: 2
                    )
            }
            if model.showProfile {
                Group {
                    HStack(spacing: 0) {
                        soul
                        if model.showSpace {
                            Spacer.fixedWidth(width / 2 - 110)
                            space
                        }
                    }
                }
            }
        }
        .animation(.easeInOut.speed(0.5), value: UUID())
    }
    
    private var soul: some View {
        VStack(spacing: 8) {
            SwiftUIObjectIconImageViewWithPlaceholder(iconImage: model.profileIcon, usecase: .dashboardSearch)
            .frame(width: 48, height: 48)
            AnytypeText(model.state.soul, style: .previewTitle2Medium, color: .Text.primary)
                .lineLimit(1)
        }
        .frame(width: 110)
    }
    
    private var space: some View {
        VStack(spacing: 8) {
            SwiftUIObjectIconImageViewWithPlaceholder(iconImage: model.spaceIcon, usecase: .dashboardSearch)
            .frame(width: 48, height: 48)
            AnytypeText(Loc.Auth.JoinFlow.Personal.Space.title, style: .previewTitle2Medium, color: .Text.primary)
        }
        .frame(width: 110)
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
