import UIKit
import SwiftUI

final class SlashMenuRealtionView: UIView, UIContentView {
    private var realtionViewModel: RelationNameValueViewModel

//    private lazy var relationView = RelationNameValueView(viewModel: realtionViewModel)
    private lazy var relationView = RelationView2(relation: currentConfiguration.relation)
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
        self.realtionViewModel = RelationNameValueViewModel(relation: configuration.relation)

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
//        let relationsView = RelationNameValueView(viewModel: realtionViewModel).asUIView()
        let relationsView = RelationView2(relation: currentConfiguration.relation).asUIView()

        addSubview(container) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -20))
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
//        realtionViewModel.relation = configuration.relation
    }
}

//private extension RelationBlockView2 {

    struct RelationView2: View {
        @State var width: CGFloat = .zero
        @State var height: CGFloat = .zero
        @State var relation: Relation

        var body: some View {
            HStack(spacing: 2) {
                AnytypeText(relation.name, style: .relation1Regular, color: .textSecondary)
                    .frame(width: width * 0.4, height: height, alignment: .topLeading)
                    .background(Color.buttonSecondaryPressed)
                    .cornerRadius(2)
                RelationValueView(relation: relation, style: .regular(allowMultiLine: true))
                    .frame(maxWidth: .infinity, minHeight: 34, alignment: .center)
                    .background(Color.buttonSecondaryPressed)
                    .cornerRadius(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(FrameCatcher { height = $0.size.height })
            }
            .background(FrameCatcher { width = $0.size.width })
        }
    }
//}
