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

protocol HomeCollectionViewInput {
    func showPage(with blockId: String)
}

// MARK: - UIViewRepresentable
struct HomeCollectionView: UIViewRepresentable {
    @Binding var showDocument: Bool
    @Binding var selectedDocumentId: String
    @EnvironmentObject var viewModel: HomeCollectionViewModel
    @Binding var documentsCell: [HomeCollectionViewCellType]
    
    let containerSize: CGSize
    
    func makeCoordinator() -> HomeCollectionViewCoordinator {
        viewModel.view = self // TODO: check if there is retain cycle
        return HomeCollectionViewCoordinator(self)
    }
    
    func makeUIView(context: Context) -> UICollectionView {
        let collectionView = configureCollectionView()
        let dataSource = configureDataSource(collectionView: collectionView)
        collectionView.delegate = context.coordinator
        collectionView.contentInset = .init(top: 200, left: 0, bottom: 0, right: 0)
        
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

// MARK: - HomeCollectionViewInput
extension HomeCollectionView: HomeCollectionViewInput {
    
    func showPage(with blockId: String) {
        showDocument = true
        selectedDocumentId = blockId
    }
}

// MARK: - Private HomeCollectionView
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
        parent.viewModel.didSelectPage(with: indexPath)
    }
}
