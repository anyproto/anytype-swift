import SwiftUI
import Combine

class OldHomeCollectionViewCoordinator: NSObject, UICollectionViewDelegate {
    var parent: OldHomeCollectionView
    var dataSource: UICollectionViewDiffableDataSource<OldHomeCollectionViewSection, OldHomeCollectionViewCellType>?
    var userActionSubscription: AnyCancellable?
    var documentCellsSubscription: AnyCancellable?
    
    init(_ collectionView: OldHomeCollectionView, viewModel: OldHomeCollectionViewModel) {
        self.parent = collectionView
        super.init()
        self.configured(viewModel: viewModel)
    }
    
    private func configured(viewModel: OldHomeCollectionViewModel) {
        self.userActionSubscription = viewModel.userActionsPublisher.sink { [weak self] value in
            switch value {
            case let .showPage(value): self?.parent.showPage(with: value)
            }
        }
        self.documentCellsSubscription = viewModel.$cellViewModels.receive(on: DispatchQueue.main).sink{ [weak self] (value) in
            self?.populate(dataSource: self?.dataSource, models: value)
        }
    }
    
    private func populate(dataSource: UICollectionViewDiffableDataSource<OldHomeCollectionViewSection, OldHomeCollectionViewCellType>?, models: [OldHomeCollectionViewCellType]) {
        var snapshot = NSDiffableDataSourceSnapshot<OldHomeCollectionViewSection, OldHomeCollectionViewCellType>()
        snapshot.appendSections([.main])
        
        snapshot.appendItems(models)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK : - OldHomeCollectionViewCoordinator
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        parent.viewModel.didSelectPage(with: indexPath)
    }
}
