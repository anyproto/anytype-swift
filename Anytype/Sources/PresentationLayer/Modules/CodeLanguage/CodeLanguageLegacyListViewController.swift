import UIKit


/// View that represents list and search bar on top
///
/// For more information, see  [Anytype design.](https://www.figma.com/file/TpUBIdjDYVWGyaarlnHIsz/Android-main?node-id=351%3A32)
final class CodeLanguageLegacyListViewController: UIViewController {
    enum Section {
        case main
    }

    private let viewModel: CodeLanguageLegacyListViewModel
    private var dataSource: UICollectionViewDiffableDataSource<Section, CodeLanguage>?

    // MARK: - Views

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .Background.secondary
        searchBar.placeholder = Loc.searchForLanguage

        return searchBar
    }()

    private lazy var collectionView: UICollectionView = {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.backgroundColor = .Background.secondary
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)

        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self

        return collectionView
    }()

    // MARK: - Lifecycle

    init(viewModel: CodeLanguageLegacyListViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        configureDataSource()
    }

    // MARK: - Setup and layut views

    private func setupViews() {
        view.backgroundColor = .Background.secondary

        view.addSubview(searchBar)
        view.addSubview(collectionView)

        setupLayout()
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Configure data source

    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, CodeLanguage> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = "\(item)"
            cell.contentConfiguration = content
            cell.contentView.backgroundColor = .Background.secondary
        }

        dataSource = UICollectionViewDiffableDataSource<Section, CodeLanguage>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: CodeLanguage) -> UICollectionViewCell? in

            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, CodeLanguage>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.items)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - UICollectionViewDelegate

extension CodeLanguageLegacyListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedItem = self.dataSource?.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        dismiss(animated: true) { [weak self] in
            self?.viewModel.onTapCodeLanguage(selectedItem)
        }
    }
}

// MARK: - UISearchBarDelegate

extension CodeLanguageLegacyListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let filteredItems = viewModel.items.filter { $0.rawValue.lowercased().hasPrefix(searchText.lowercased()) }

        var snapshot = NSDiffableDataSourceSnapshot<Section, CodeLanguage>()
        snapshot.appendSections([.main])
        snapshot.appendItems(filteredItems)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}
