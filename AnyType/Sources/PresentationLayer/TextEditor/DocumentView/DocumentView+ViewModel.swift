//
//  DocumentView+ViewModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

extension DocumentView {
    class ViewModel: DocumentViewModel {
        @Published var buildersRows: [Row] = [] {
            didSet {
                self.objectWillChange.send()
            }
        }
        var anyFieldUpdateSubject: PassthroughSubject<String, Never> = .init()
        var anyFieldUpdateSubscription: AnyCancellable?
//        var onAnyFieldUpdate: PassthroughSubject<(Block.ID, String), Never> = .init()
        var buildersSubscription: AnyCancellable?
        override init(documentId: String?) {
            super.init(documentId: documentId)
            self.buildersSubscription = self.$builders.sink { value in
                self.buildersRows = value.compactMap(Row.init)
            }
            
            self.anyFieldUpdateSubscription = self.$builders.map{$0.compactMap{$0 as? TextBlocksViews.Base.BlockViewModel}}.flatMap{
                Publishers.MergeMany($0.map{$0.$text})
            }.subscribe(self.anyFieldUpdateSubject)
        }
    }
//    typealias ViewModel = DocumentViewModel
}

// MARK: TableViewModelProtocol
extension DocumentView.ViewModel: TableViewModelProtocol {
    func numberOfSections() -> Int {
        1
    }
    
    func countOfElements(at: Int) -> Int {
        self.builders.count
    }
    
    func section(at: Int) -> DocumentView.ViewModel.Section {
        .init()
    }
    
    func element(at: IndexPath) -> DocumentView.ViewModel.Row {
        guard self.builders.indices.contains(at.row) else {
            return .init(builder: TextBlocksViews.Base.BlockViewModel.empty)
        }
        return .init(builder: self.builders[at.row])
    }
    
    struct Section {
        var section: Int = 0
        static var first: Section = .init()
        init() {}
    }
    struct Row {
        var builder: BlockViewBuilderProtocol
    }
}

extension DocumentView.ViewModel.Section: Hashable {}
extension DocumentView.ViewModel.Row: Hashable, Equatable {
    static func == (lhs: DocumentView.ViewModel.Row, rhs: DocumentView.ViewModel.Row) -> Bool {
        lhs.builder.id == rhs.builder.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.builder.id)
    }
}
