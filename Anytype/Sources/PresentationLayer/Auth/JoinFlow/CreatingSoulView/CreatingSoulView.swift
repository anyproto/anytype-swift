import SwiftUI

struct CreatingSoulView: View {
    
    @StateObject private var model: CreatingSoulViewModel
    
    init(state: JoinFlowState, output: JoinFlowStepOutput?) {
        _model = StateObject(wrappedValue: CreatingSoulViewModel(state: state, output: output))
    }
    
    var body: some View {
        GeometryReader { geo in
            content(width: geo.size.width)
        }
        .padding(.horizontal, UIDevice.isPad ? 75 : 0)
    }
    
    private func content(width: CGFloat) -> some View {
        VStack(alignment: .center, spacing: 0) {
            AnytypeText(
                model.showSpace ? Loc.Auth.JoinFlow.Setting.Space.title : Loc.Auth.JoinFlow.Creating.Soul.title,
                style: .bodyRegular
            )
            .foregroundColor(.Auth.inputText)
            
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
                        width: model.showSpace ? width / Constants.scaleFactor : 0,
                        height: 2
                    )
                    .opacity(model.showSpace ? 1 : 0)
                    .padding(.trailing, Constants.imageDimension / 2)
            }
            if model.showProfile {
                space
                    .offset(x: model.showSpace ? width / (Constants.scaleFactor * 2) : 0)
                    .opacity(model.showSpace ? 1 : 0)
                soul
                    .offset(x: model.showSpace ? -width / (Constants.scaleFactor * 2) : 0)
            } else {
                VStack(spacing: 0) {
                    Spacer.fixedHeight(21)
                    DotsView()
                        .frame(width: Constants.imageDimension, height: 6)
                }
            }
        }
    }
    
    private var soul: some View {
        VStack(spacing: 8) {
            IconView(icon: model.profileIcon)
                .frame(width: Constants.imageDimension, height: Constants.imageDimension)
            AnytypeText(model.soulName, style: .calloutRegular)
                .foregroundColor(.Auth.body)
                .frame(width: 80)
                .truncationMode(.middle)
                .lineLimit(1)
        }
        .frame(width: Constants.itemWidth)
    }
    
    private var space: some View {
        VStack(spacing: 8) {
            IconView(icon: model.spaceIcon)
                .frame(width: Constants.imageDimension, height: Constants.imageDimension)
            AnytypeText(Loc.Spaces.Accessibility.personal, style: .calloutRegular)
                .foregroundColor(.Auth.body)
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
        CreatingSoulView(state: JoinFlowState(), output: nil)
    }
}
