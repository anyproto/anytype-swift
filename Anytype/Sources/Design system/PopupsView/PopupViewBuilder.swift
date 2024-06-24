@MainActor
final class PopupViewBuilder {

    static func createCheckPopup<ViewModel: CheckPopupViewViewModelProtocol>(viewModel: ViewModel) -> AnytypePopup {
        let view = CheckPopupView(viewModel: viewModel)
        return AnytypePopup(contentView: view)
    }

    static func createWaitingPopup(text: String) -> AnytypePopup {
        let view = WaitingPopupView(text: text)
            .horizontalReadabilityPadding(8)
        return AnytypePopup(
            contentView: view,
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: false, dismissOnBackdropView: false)
        )
    }
}

