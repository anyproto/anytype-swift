import UIKit
import SwiftUI

final class RelationBlockView: BaseBlockView<RelationBlockContentConfiguration> {
    // MARK: - Views

//    private lazy var relationsView: UIView = {
//        return UIView()
//    }()

    fileprivate lazy var relationView = RelationView(relation: currentConfiguration.relation)

    // MARK: - Private variables

    override func update(with configuration: RelationBlockContentConfiguration) {
        super.update(with: configuration)

        relationView.relation = configuration.relation
    }

    override func setupSubviews() {
        super.setupSubviews()
        setupLayout()
    }

    func setupLayout() {
        let relationsView = RelationView(viewModel: currentConfiguration.viewModel).asUIView()

        addSubview(relationsView) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: 20, bottom: -2, right: -20))
        }
    }
}

private extension RelationBlockView {

    struct RelationView: View {
        @State var width: CGFloat = .zero
        @State var height: CGFloat = .zero
        @State var relation: Relation

        var body: some View {
            HStack(spacing: 2) {
                AnytypeText(relation.name, style: .relation1Regular, color: .textSecondary)
                    .frame(width: width * 0.4, height: height, alignment: .topLeading)
                    .background(Color.buttonSecondaryPressed)
                    .cornerRadius(2)
                RelationValueViewProvider.relationView(relation, style: .regular(allowMultiLine: true))
                    .frame(maxWidth: .infinity, minHeight: 34, alignment: .center)
                    .background(Color.buttonSecondaryPressed)
                    .cornerRadius(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(FrameCatcher { height = $0.size.height })
            }
            .background(FrameCatcher { width = $0.size.width })
        }
    }
}
