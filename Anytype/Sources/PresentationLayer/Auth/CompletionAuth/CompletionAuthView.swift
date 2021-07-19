import SwiftUI

protocol CompletionAuthViewDelegate: AnyObject {
    func showDashboardDidTap()
}

struct CompletionAuthView: View {
    // TODO: move creating to assembly. Move coordinator to viewModel
    @State var viewModel: CompletionAuthViewModel
    weak var delegate: CompletionAuthViewDelegate?
    
    var body: some View {
        ZStack {
            Gradients.authBackground()
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 0) {
                    ImageWithCircleBackgroundView(image: Image.auth.congrats, backgroundColor: UIColor.init(named: "background"))
                        .frame(width: 64, height: 64)
                    AnytypeText("Congratulations!", style: .bodyBold)
                        .padding(.top, 16)
                    AnytypeText("CongratulationDescription", style: .body)
                        .padding(.top, 10)
                    StandardButton(disabled: false, text: "Let’s start!", style: .primary) {
                        self.delegate?.showDashboardDidTap()
                    }
                    .padding(.top, 18)
                }
                .padding([.leading, .trailing, .top], 20)
                .padding(.bottom, 16)
                .background(Color.background)
                .cornerRadius(12)
            }
            .padding()
            .onAppear {
                viewModel.viewLoaded()
            }
        }
        .navigationBarHidden(true)
        .modifier(LogoOverlay())
    }
}

struct CompletionAuthView_Previews: PreviewProvider {
    static var previews: some View {
        let seedService = ServiceLocator.shared.seedService()
        let completionViewModel = CompletionAuthViewModel(coordinator: CompletionAuthViewCoordinator(),
                                                          loginStateService: LoginStateService(seedService: seedService))
        return CompletionAuthView(viewModel: completionViewModel, delegate: nil)
    }
}
