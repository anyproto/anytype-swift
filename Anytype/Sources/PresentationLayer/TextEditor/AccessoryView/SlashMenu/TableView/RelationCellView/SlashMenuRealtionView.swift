import UIKit
import SwiftUI

final class SlashMenuRealtionView: UIView, UIContentView {
    private var realtionViewModel: RelationNameValueViewModel
    private let container = UIView()

    private var currentConfiguration: SlashMenuRealtionContentConfiguration
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let configuration = newValue as? SlashMenuRealtionContentConfiguration else {
                return
            }
            guard configuration != currentConfiguration else {
                return
            }

            currentConfiguration = configuration
            apply(with: configuration)
        }
    }

    init(configuration: SlashMenuRealtionContentConfiguration) {
        self.currentConfiguration = configuration
        self.realtionViewModel = RelationNameValueViewModel(
            relation: configuration.relation,
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
        let relationsView = EnhancedRelationView(viewModel: realtionViewModel).asUIView()

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

    func apply(with configuration: SlashMenuRealtionContentConfiguration) {
        realtionViewModel.relation = configuration.relation
        realtionViewModel.isHighlighted = false

        if configuration.currentConfigurationState?.isHighlighted ?? false {
            realtionViewModel.isHighlighted = true
        }
    }
}

struct EnhancedRelationView: View {
    @ObservedObject var viewModel: RelationNameValueViewModel

    var body: some View {
        GeometryReader { _ in
            RelationNameValueView(viewModel: viewModel)
                .background(viewModel.isHighlighted ? Color.Background.highlightedOfSelected : Color.Background.primary)
        }
    }
}
