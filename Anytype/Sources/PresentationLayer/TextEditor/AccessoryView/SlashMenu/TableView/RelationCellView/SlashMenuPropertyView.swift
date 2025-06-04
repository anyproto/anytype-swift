import UIKit
import SwiftUI

final class SlashMenuPropertyView: UIView, UIContentView {
    private var realtionViewModel: PropertyNameValueViewModel
    private let container = UIView()

    private var currentConfiguration: SlashMenuPropertyContentConfiguration
    var configuration: any UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let configuration = newValue as? SlashMenuPropertyContentConfiguration else {
                return
            }
            guard configuration != currentConfiguration else {
                return
            }

            currentConfiguration = configuration
            apply(with: configuration)
        }
    }

    init(configuration: SlashMenuPropertyContentConfiguration) {
        self.currentConfiguration = configuration
        self.realtionViewModel = PropertyNameValueViewModel(
            property: configuration.property,
            action: { }
        )

        super.init(frame: .zero)

        setupSubviews()
        apply(with: configuration)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Setup view

    func setupSubviews() {
        let relationsView = EnhancedPropertyView(viewModel: realtionViewModel).asUIView()

        addSubview(container) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            $0.height.equal(to: 56)
        }

        container.addSubview(relationsView) {
            $0.height.equal(to: 30)
            $0.centerY.equal(to: container.centerYAnchor)
            $0.leading.equal(to: container.leadingAnchor)
            $0.trailing.equal(to: container.trailingAnchor)
        }
    }

    // MARK: - Apply configuration

    func apply(with configuration: SlashMenuPropertyContentConfiguration) {
        realtionViewModel.property = configuration.property
        realtionViewModel.isHighlighted = false

        if configuration.currentConfigurationState?.isHighlighted ?? false {
            realtionViewModel.isHighlighted = true
        }
    }
}

struct EnhancedPropertyView: View {
    @ObservedObject var viewModel: PropertyNameValueViewModel

    var body: some View {
        GeometryReader { _ in
            PropertyNameValueView(viewModel: viewModel)
                .background(viewModel.isHighlighted ? Color.Background.highlightedMedium : Color.Background.primary)
        }
    }
}
