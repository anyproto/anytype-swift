//
//  HomeCollectionView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

enum HomeCollectionViewSection {
    case main
}

struct HomeCollectionView: UIViewRepresentable {
    @Binding var showDocument: Bool
    @Binding var selectedDocumentId: String
    @EnvironmentObject var viewModel: HomeCollectionViewModel
    @Binding var documentsCell: [HomeCollectionViewCellType]
    
    let containerSize: CGSize
    
    // MARK: - UIViewRepresentable
    
    func makeCoordinator() -> HomeCollectionViewCoordinator {
        HomeCollectionViewCoordinator(self)
    }
    
    func makeUIView(context: Context) -> UICollectionView {
        let collectionView = configureCollectionView()
        let dataSource = configureDataSource(collectionView: collectionView)
        collectionView.delegate = context.coordinator
        
        populate(dataSource: dataSource)
        context.coordinator.dataSource = dataSource
        
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        if let dataSource = context.coordinator.dataSource {
            populate(dataSource: dataSource)
        }
    }
    
    private func populate(dataSource: UICollectionViewDiffableDataSource<HomeCollectionViewSection, HomeCollectionViewCellType>) {
        var snapshot = NSDiffableDataSourceSnapshot<HomeCollectionViewSection, HomeCollectionViewCellType>()
        snapshot.appendSections([.main])
        
        snapshot.appendItems(documentsCell)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension HomeCollectionView {
    
    private func configureCollectionView() -> UICollectionView {
        let rect = CGRect(origin: .zero, size: containerSize)
        let collectionView = UICollectionView(frame: rect, collectionViewLayout: createCollectionLayout())
        collectionView.backgroundColor = .clear
        collectionView.register(HomeCollectionViewDocumentCell.self, forCellWithReuseIdentifier: HomeCollectionViewDocumentCell.reuseIdentifer)
        collectionView.register(HomeCollectionViewPlusCell.self, forCellWithReuseIdentifier: HomeCollectionViewPlusCell.reuseIdentifer)
        
        return collectionView
    }
    
    private func configureDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<HomeCollectionViewSection, HomeCollectionViewCellType> {
        let dataSource = UICollectionViewDiffableDataSource<HomeCollectionViewSection, HomeCollectionViewCellType>(collectionView: collectionView) { collectionView, indexPath, cellType in
            
            switch cellType {
            case .document(let viewModel):
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewDocumentCell.reuseIdentifer, for: indexPath) as? HomeCollectionViewDocumentCell {
                    cell.updateWithModel(viewModel: viewModel)
                    return cell
                }
            case .plus:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewPlusCell.reuseIdentifer, for: indexPath)
                return cell
            }
            fatalError("Cannot create new cell")
        }
        
        return dataSource
    }
    
    private func createCollectionLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, layoutEnvironment in
            let columns = Int(layoutEnvironment.container.effectiveContentSize.width / 160)
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(160), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(112))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = .fixed(16.0)
            
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16.0
            
            return section
        }
        
        return layout
    }
    
}

// MARK: - Coordinator

class HomeCollectionViewCoordinator: NSObject {
    var parent: HomeCollectionView
    var dataSource: UICollectionViewDiffableDataSource<HomeCollectionViewSection, HomeCollectionViewCellType>?
    
    init(_ collectionView: HomeCollectionView) {
        self.parent = collectionView
    }
}

extension HomeCollectionViewCoordinator: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        parent.showDocument = true
        
//        guard parent.viewModel.documentsHeaders?.headers.indices.contains(indexPath.row) ?? false,
//            let documentId = parent.viewModel.documentsHeaders?.headers[indexPath.row].id else { return }
        
//        parent.selectedDocumentId = documentId
        
        parent.viewModel.didSelectPage(with: indexPath)
        
    }
    
}
