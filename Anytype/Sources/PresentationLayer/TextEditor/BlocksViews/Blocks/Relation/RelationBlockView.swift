import UIKit
import SwiftUI

final class RelationBlockView: BaseBlockView<RelationBlockContentConfiguration>, ObservableObject {
    @Published var heightConstraint: NSLayoutConstraint!
    @Published var relation: Relation?

    // MARK: - Views

    fileprivate lazy var relationView = RelationView(delegate: self)
    private let container = UIView()


    // MARK: - BaseBlockView

    override func update(with configuration: RelationBlockContentConfiguration) {
        super.update(with: configuration)

        relation = configuration.relation
    }

    override func setupSubviews() {
        super.setupSubviews()
        setupLayout()
    }

    // MARK: - Setup view

    static var number: Int = 0
    func setupLayout() {
        let relationsView = relationView.asUIView()

        addSubview(relationsView) {
            heightConstraint = $0.height.equal(to: 32)
            $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: 20, bottom: -2, right: -20))
        }
    }
}

private extension RelationBlockView {

    struct RelationView: View {
        @State private var width: CGFloat = .zero
        @State private var height: CGFloat = .zero
        @ObservedObject var delegate: RelationBlockView

        var body: some View {
            if let relation = delegate.relation {
                HStack(spacing: 2) {
                    AnytypeText(relation.name, style: .relation1Regular, color: .textSecondary)
                        .padding([.top], 5)
                        .frame(width: width * 0.4, height:  height, alignment: .topLeading)
                        .background(Color.buttonSecondaryPressed)
                        .cornerRadius(2)
                    RelationValueView(relation: relation, style: .regular(allowMultiLine: true))
                        .padding([.top], 5)
                        .if(height > LayoutConstants.minHeight) {
                            $0.padding(.bottom, 13)
                        }
                        .frame(maxWidth: .infinity, minHeight: LayoutConstants.minHeight, alignment: .topLeading)
                        .background(Color.buttonSecondaryPressed)
                        .cornerRadius(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .readSize {
                            height = $0.height
                            delegate.heightConstraint.constant = height
                        }
                }
                .readSize { width = $0.width }
            }
        }

        private enum LayoutConstants {
            static let minHeight: CGFloat = 32
        }
    }
}
