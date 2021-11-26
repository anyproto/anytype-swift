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
        addSubview(relationView.asUIView()) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0))
        }
    }
}

private extension RelationBlockView {

    struct RelationView: View {
        @State var relation: Relation

        var body: some View {
            GeometryReader { metrics in
                HStack(spacing: 2) {
                    AnytypeText(relation.name, style: .relation1Regular, color: .textSecondary)
                        .frame(width: metrics.size.width * 0.4)
                        .background(Color.buttonSecondaryPressed)
                    RelationValueViewProvider.relationView(relation, style: .regular)
                        .background(Color.buttonSecondaryPressed)
                }
            }
        }
    }
}
