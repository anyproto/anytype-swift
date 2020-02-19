//
//  BlockModel+Parser+ModelBuilder.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 26.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

// MARK: Checker
extension BlockModels.Parser {
    class Comparator {
        // MARK: MetaBlockType
        // Brief: BlockType -> String
        // Overview:
        // Maps BlockType ( .text, .image, .video ) to String.
        // This type automatically adopts Hashable and Equatable protocols and can be used as key in dictionaries.
        enum MetaBlockType: String {
            case text, image, video
            
            static func from(_ block: MiddlewareBlockInformationModel) -> Self {
                switch block.content {
                case .text(_): return .text
                case .image(_): return .image
                case .video: return .video
                    // TODO:
                // add others
                default: return .text
                }
            }
        }
        static func from(_ block: MiddlewareBlockInformationModel) -> MetaBlockType {
            return .from(block)
        }

        static func same(_ lhs: MiddlewareBlockInformationModel, _ rhs: MiddlewareBlockInformationModel) -> Bool {
            switch (lhs.content, rhs.content) {
            case let (.text(left), .text(right)): return left.contentType == right.contentType
            case let (.image(left), .image(right)): return left.contentType == right.contentType
            case (.video, .video): return true
            default: return false
            }
        }
    }
}

// MARK: Clustering
extension BlockModels.Parser {
    class ClusteringApplier {
        static public func apply(blocks: [MiddlewareBlockInformationModel]) -> [[MiddlewareBlockInformationModel]] {
            DataStructures.GroupBy.group(blocks, by: Comparator.same)
        }
    }
}

// MARK: Model Builder
extension BlockModels.Parser {
    class BaseModelBuilder {
        /// - Parameter list: List of blocks that are converted straightforward from Protobuf blocks.
        private func group(_ list: [Block]) -> [[MiddlewareBlockInformationModel]] {
            // iterate over each element and ask yourself if this element could fulfill previous container.
            ClusteringApplier.apply(blocks: list)
        }
        
        // TODO: Override.
        open func solve(entry: MiddlewareBlockInformationModel, of cluster: [MiddlewareBlockInformationModel]) -> [Model] {
            // write special solvers that map cluster to a model.
            return []
        }
        
        private func solve(cluster: [MiddlewareBlockInformationModel]) -> [Model] {
            guard let entry = cluster.first else { return [] }
            return self.solve(entry: entry, of: cluster)
        }
            
        public func solve(_ clusters: [[MiddlewareBlockInformationModel]]) -> [Model] {
            // we should iterate over cluster and ask ourselves what should we do with it.
            clusters.flatMap(self.solve)
        }
    }
}

// MARK: Compound Model Builder
extension BlockModels.Parser {
    class CompoundModelBuilder: BaseModelBuilder {
        var textModelBuilder: BaseModelBuilder = TextModelBuilder()
        var imageModelBuilder: BaseModelBuilder = ImageModelBuilder()
        
        func find(by entry: MiddlewareBlockInformationModel) -> BaseModelBuilder? {
            switch Comparator.from(entry) {
            case .text: return self.textModelBuilder
            case .image: return self.imageModelBuilder
            default: return nil
            }
        }
        
        override func solve(entry: MiddlewareBlockInformationModel, of cluster: [MiddlewareBlockInformationModel]) -> [BlockModels.Parser.Model] {
            self.find(by: entry)?.solve(entry: entry, of: cluster) ?? []
        }
    }
}

// MARK: Custom Model Builders
// MARK: Custom Model Builders / Text
extension BlockModels.Parser {
    class TextModelBuilder: BaseModelBuilder {
        override func solve(entry: MiddlewareBlockInformationModel, of cluster: [MiddlewareBlockInformationModel]) -> [BlockModels.Parser.Model] {
            switch entry.content {
            case let .text(value):
                switch value.contentType {
                case .numbered: return [Model.init(indexPath: BlockModels.Utilities.IndexGenerator.rootID(), blocks: cluster.compactMap{Model.init(information: .init(information: $0))}).with(kind: .meta)]
                default: return cluster.compactMap{BlockModels.Parser.Model.init(information: .init(information: $0))}
                }
            default: return []
            }
        }
    }
}

// MARK: Custom Model Builders / Images
extension BlockModels.Parser {
    class ImageModelBuilder: BaseModelBuilder {
        override func solve(entry: MiddlewareBlockInformationModel, of cluster: [MiddlewareBlockInformationModel]) -> [BlockModels.Parser.Model] {
            switch entry.content {
            case .image(_): return cluster.compactMap{BlockModels.Parser.Model.init(information: .init(information: $0))}
            default: return []
            }
        }
    }
}

