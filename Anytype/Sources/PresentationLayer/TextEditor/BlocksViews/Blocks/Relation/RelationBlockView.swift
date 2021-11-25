import UIKit
import SwiftUI

final class RelationBlockView<ViewModel: RelationBlockViewModelProtocol>: BaseBlockView<RelationBlockContentConfiguration<ViewModel>> {
    // MARK: - Views

    private lazy var relationsView: UIView = {
        return UIView()
    }()

    // MARK: - Private variables

    override func update(with configuration: RelationBlockContentConfiguration<ViewModel>) {
        super.update(with: configuration)
    }

    override func setupSubviews() {
        super.setupSubviews()
        setupLayout()
    }
}

private extension RelationBlockView  {

    func setupLayout() {
        let relationsView = RelationView(viewModel: currentConfiguration.viewModel).asUIView()

        addSubview(relationsView) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0))
        }
    }
}

private extension RelationBlockView {

    struct RelationView<ViewModel: RelationBlockViewModelProtocol>: View {
        @ObservedObject var viewModel: ViewModel

        var body: some View {
            GeometryReader { metrics in
                HStack(spacing: 2) {
                    AnytypeText(viewModel.relation.name, style: .relation1Regular, color: .textSecondary)
                        .frame(width: metrics.size.width * 0.4)
                        .background(Color.buttonSecondaryPressed)
                    RelationValueViewProvider.relationView(viewModel.relation, style: .regular)
                        .background(Color.buttonSecondaryPressed)
                }
            }
        }
    }
}
