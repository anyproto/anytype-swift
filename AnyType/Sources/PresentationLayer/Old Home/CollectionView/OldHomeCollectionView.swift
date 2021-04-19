import SwiftUI
import Combine

enum OldHomeCollectionViewSection {
    case main
}

struct OldHomeCollectionView: UIViewRepresentable {
    @ObservedObject var viewModel: OldHomeCollectionViewModel
    
    @Binding var showDocument: Bool
    @Binding var selectedDocumentId: String
    @Binding var cellModels: [OldHomeCollectionViewCellType]
    
    let containerSize: CGSize
    
    init(
        viewModel: OldHomeCollectionViewModel,
        showDocument: Binding<Bool>,
        selectedDocumentId: Binding<String>,
        cellsModels: Binding<[OldHomeCollectionViewCellType]>,
        containerSize: CGSize
    ) {
        self.viewModel = viewModel
        
        self._showDocument = showDocument
        self._selectedDocumentId = selectedDocumentId
        self._cellModels = cellsModels
        
        self.containerSize = containerSize
    }
    
    func makeCoordinator() -> OldHomeCollectionViewCoordinator {
        .init(self, viewModel: self.viewModel)
    }
    
    func makeUIView(context: Context) -> UICollectionView {
        let collectionView = configureCollectionView()
        let dataSource = configureDataSource(collectionView: collectionView)
        collectionView.delegate = context.coordinator
//        collectionView.contentInset = .init(top: 200, left: 0, bottom: 0, right: 0)
        collectionView.alwaysBounceVertical = true
//        populate(dataSource: dataSource)
        context.coordinator.dataSource = dataSource
        
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
//        if let dataSource = context.coordinator.dataSource {
//            populate(dataSource: dataSource)
//        }
    }
    
    private func populate(dataSource: UICollectionViewDiffableDataSource<OldHomeCollectionViewSection, OldHomeCollectionViewCellType>) {
        var snapshot = NSDiffableDataSourceSnapshot<OldHomeCollectionViewSection, OldHomeCollectionViewCellType>()
        snapshot.appendSections([.main])
        
        snapshot.appendItems(self.cellModels)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Show Page
    func showPage(with blockId: String) {
        self.showDocument = true
        self.selectedDocumentId = blockId
    }

    // MARK: - Private OldHomeCollectionView
    private func configureCollectionView() -> UICollectionView {
        let rect = CGRect(origin: .zero, size: containerSize)
        let collectionView = UICollectionView(frame: rect, collectionViewLayout: createCollectionLayout())
        collectionView.backgroundColor = .clear
        collectionView.register(OldHomeCollectionViewDocumentCell.self, forCellWithReuseIdentifier: OldHomeCollectionViewDocumentCell.reuseIdentifer)
        collectionView.register(OldHomeCollectionViewPlusCell.self, forCellWithReuseIdentifier: OldHomeCollectionViewPlusCell.reuseIdentifer)
        
        return collectionView
    }
    
    private func configureDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<OldHomeCollectionViewSection, OldHomeCollectionViewCellType> {
        let dataSource = UICollectionViewDiffableDataSource<OldHomeCollectionViewSection, OldHomeCollectionViewCellType>(collectionView: collectionView) { collectionView, indexPath, cellType in
            
            switch cellType {
            case .document(let viewModel):
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OldHomeCollectionViewDocumentCell.reuseIdentifer, for: indexPath) as? OldHomeCollectionViewDocumentCell {
                    cell.updateWithModel(viewModel: viewModel)
                    return cell
                }
            case .plus:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OldHomeCollectionViewPlusCell.reuseIdentifer, for: indexPath)
                return cell
            }
            fatalError("Cannot create new cell")
        }
        
        return dataSource
    }
    
    private func createCollectionLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _,_ in 
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(155), heightDimension: .estimated(112))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(112))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            group.interItemSpacing = .fixed(10.0)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 10.0
            
            return section
        }
        
        return layout
    }
}
