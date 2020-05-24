//
//  EmojiPickerViewController.swift
//  AnyType
//
//  Created by Valentine Eyiubolu on 4/27/20.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit
import Combine
import os

private extension Logging.Categories {
    static let emojiPickerViewController: Self = "EmojiPicker.ViewController"
}

enum EmojiPicker {
    
    class ViewController: UIViewController {
        
        /// Model
        typealias ViewModel = EmojiPicker.ViewModel
        
        private var viewModel: ViewModel
        
        // Variables
        private var layout: Layout = .init()
        private var style: Style = .presentation
        
        /// Combine
        private var subscriptions: Set<AnyCancellable> = []
        
        private lazy var collectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            
            var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.backgroundColor = .clear
            return collectionView
        }()
        
        private var emptyView: EmojiPicker.ViewController.EmptyView = {
            let view = EmptyView()
            view.backgroundColor = .clear
            view.isHidden = true
            view.translatesAutoresizingMaskIntoConstraints = false
            
            return view
        }()
        
        private lazy var searchView: SearchTextFieldView = {
            let view = SearchTextFieldView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private lazy var topLine: UIImageView = {
            let imageView = UIImageView()
            imageView.backgroundColor = self.style.topLineColor()
            imageView.layer.cornerRadius = self.layout.topLineCornerRadius
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.view.backgroundColor = .white
            
            self.setupUI()
            self.setupInteractions()
        }
        
        /// Initialization
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupInteractions() {
            self.searchView.$text.sink { [weak self] (text) in
                self?.viewModel.filterEmojies(with: text)
            }.store(in: &subscriptions)
            
            self.viewModel.$searchResult.sink(receiveValue: { [weak self] (result) in
                self?.handle(searchResult: result)
            }).store(in: &subscriptions)
            
            self.viewModel.userEventSubject.sink { [weak self] (event) in
                switch event {
                case .shouldDismiss:
                    self?.dismiss(animated: true, completion: nil)
                default:
                    let logger = Logging.createLogger(category: .emojiPickerViewController)
                    os_log(.debug, log: logger, "We don't handle this event: %@", String(describing: event))
                }
            }.store(in: &subscriptions)
        }
        
        private func handle(searchResult: EmojiPicker.ViewModel.SearchResult) {
            self.emptyView.isHidden = !searchResult.notFound
            self.collectionView.isHidden = searchResult.notFound
            self.emptyView.updateTitle(with: searchResult.keyword)
            self.collectionView.reloadData()
        }
    }
}

// MARK: Layout
private extension EmojiPicker.ViewController {
    struct Layout {
        var itemSize = CGSize(width: 54, height: 44)
        var sectionInsets = UIEdgeInsets(top: 13, left: 16, bottom: 15, right: 16)
        var contentInsets = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        var sectionHeaderHeight: CGFloat = 20
        
        var topLineSize = CGSize(width: 48, height: 4)
        var topLineTopPadding: CGFloat = 6
        
        var searchViewHeight: CGFloat = 40
        var searchViewInsets = UIEdgeInsets(top: 23, left: 20, bottom: 0, right: -20)
    
        var emptyViewInsets = UIEdgeInsets(top: 92, left: 20, bottom: 0, right: -20)
        
        var topLineCornerRadius: CGFloat = 2
    }
}

// MARK: - Style
extension EmojiPicker.ViewController {
    enum Style {
        case presentation
        
        func topLineColor() -> UIColor {
            #colorLiteral(red: 0.8745098039, green: 0.8666666667, blue: 0.8156862745, alpha: 1)
        }
        
    }
}

// MARK: - Setup UI
extension EmojiPicker.ViewController {
    
    private func setupUI() {
        self.setupElements()
        self.setupCollectionView()
        self.setupLayout()
    }

    private func setupElements() {
        self.view.addSubview(topLine)
        self.view.addSubview(collectionView)
        self.view.addSubview(searchView)
        self.view.addSubview(emptyView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            topLine.widthAnchor.constraint(equalToConstant: self.layout.topLineSize.width),
            topLine.heightAnchor.constraint(equalToConstant: self.layout.topLineSize.height),
            topLine.topAnchor.constraint(equalTo: view.topAnchor, constant: self.layout.topLineTopPadding),
            topLine.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: self.layout.searchViewInsets.left),
            searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: self.layout.searchViewInsets.right),
            searchView.topAnchor.constraint(equalTo: view.topAnchor, constant: self.layout.searchViewInsets.top),
            searchView.heightAnchor.constraint(equalToConstant: self.layout.searchViewHeight),
        
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: self.layout.emptyViewInsets.left),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: self.layout.emptyViewInsets.right),
            emptyView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: self.layout.emptyViewInsets.top),
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = .init(width: self.layout.itemSize.width, height: self.layout.itemSize.height)
        layout.sectionInset = self.layout.sectionInsets
        collectionView.collectionViewLayout = layout

        collectionView.contentInset = self.layout.contentInsets
        
        // register cells and headers
        collectionView.register(EmojiPicker.Cell.self, forCellWithReuseIdentifier: EmojiPicker.Cell.reuseIdentifer)
        collectionView.register(EmojiPicker.HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiPicker.HeaderCollectionReusableView.reuseIdentifer)
    }
    
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension EmojiPicker.ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModel.countOfElements(at: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiPicker.Cell.reuseIdentifer, for: indexPath) as? EmojiPicker.Cell {
           
            if let item = self.viewModel.element(at: indexPath) {
                cell.emojiLabel.text = item.unicode
            }
            return cell
        }
        return .init()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch (kind, collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EmojiPicker.HeaderCollectionReusableView.reuseIdentifer, for: indexPath)) {
        case (UICollectionView.elementKindSectionHeader, let value as EmojiPicker.HeaderCollectionReusableView):
            value.titleLabel.text = self.viewModel.sectionTitle(at: indexPath).uppercased()
            return value
        default:
            return .init()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
         .init(width: collectionView.frame.width, height: self.layout.sectionHeaderHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.didSelectItem(at: indexPath)
    }
    
}
