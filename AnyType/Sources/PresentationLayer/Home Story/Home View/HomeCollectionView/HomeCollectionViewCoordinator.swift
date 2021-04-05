import SwiftUI
import Combine

class HomeCollectionViewCoordinator: NSObject, UICollectionViewDelegate {
    var parent: HomeCollectionView
    var dataSource: UICollectionViewDiffableDataSource<HomeCollectionViewSection, HomeCollectionViewCellType>?
    var userActionSubscription: AnyCancellable?
    var documentCellsSubscription: AnyCancellable?
    
    init(_ collectionView: HomeCollectionView, viewModel: HomeCollectionViewModel) {
        self.parent = collectionView
        super.init()
        self.configured(viewModel: viewModel)
    }
    
    private func configured(viewModel: HomeCollectionViewModel) {
        self.userActionSubscription = viewModel.userActionsPublisher.sink { [weak self] value in
            switch value {
            case let .showPage(value): self?.parent.showPage(with: value)
            }
        }
        self.documentCellsSubscription = viewModel.$documentsViewModels.receive(on: RunLoop.main).sink{ [weak self] (value) in
            self?.populate(dataSource: self?.dataSource, models: value)
        }
    }
    
    private func populate(dataSource: UICollectionViewDiffableDataSource<HomeCollectionViewSection, HomeCollectionViewCellType>?, models: [HomeCollectionViewCellType]) {
        var snapshot = NSDiffableDataSourceSnapshot<HomeCollectionViewSection, HomeCollectionViewCellType>()
        snapshot.appendSections([.main])
        
        snapshot.appendItems(models)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK : - HomeCollectionViewCoordinator
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        parent.viewModel.didSelectPage(with: indexPath)
    }
}
