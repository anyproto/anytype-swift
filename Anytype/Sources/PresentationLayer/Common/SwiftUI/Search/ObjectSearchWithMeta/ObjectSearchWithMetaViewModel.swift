import Services
import Combine
import Foundation
import OrderedCollections
import AnytypeCore

@MainActor
final class ObjectSearchWithMetaViewModel: ObservableObject {
    
    @Injected(\.searchWithMetaService)
    private var searchWithMetaService: any SearchWithMetaServiceProtocol
    @Injected(\.searchWithMetaModelBuilder)
    private var searchWithMetaModelBuilder: any SearchWithMetaModelBuilderProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    
    private let dateFormatter = AnytypeRelativeDateTimeFormatter()
    
    @Published var searchText = ""
    @Published var sections = [ListSectionData<String?, SearchWithMetaModel>]()
    @Published var objectTypesModelsToCreate = [ObjectSearchCreationModel]()
    @Published var dismiss = false
    
    private weak var output: (any ObjectSearchWithMetaModuleOutput)?
    private var searchResult = [SearchResultWithMeta]()
    
    let moduleData: ObjectSearchWithMetaModuleData
    var isInitial = true
    
    init(data: ObjectSearchWithMetaModuleData, output: (any ObjectSearchWithMetaModuleOutput)?) {
        self.moduleData = data
        self.output = output
    }
    
    func subscribeOnTypes() async {
        for await _ in objectTypeProvider.syncPublisher.values {
            let objectTypes = objectTypeProvider.objectTypes(spaceId: moduleData.spaceId).filter {
                moduleData.type.objectTypesKeys.contains($0.uniqueKey)
            }
            updateObjectTypesModels(objectTypes: objectTypes)
        }
    }
    
    func search() async {
        do {
            if needDelay() {
                try await Task.sleep(seconds: 0.3)
            }

            searchResult = try await searchWithMetaService.search(
                text: searchText,
                spaceId: moduleData.spaceId,
                layouts: moduleData.type.section.supportedLayouts,
                sorts: buildSorts(),
                excludedObjectIds: moduleData.excludedObjectIds
            )
            
            updateInitialStateIfNeeded()
            updateSections()
            
        } catch is CancellationError {
            // Ignore cancellations. That means we was run new search.
        } catch {
            sections = []
        }
        
        AnytypeAnalytics.instance().logSearchInput(spaceId: moduleData.spaceId)
    }
    
    func onSelect(searchData: SearchWithMetaModel) {
        guard let details = searchResult.first(where: { $0.objectDetails.id == searchData.id} )?.objectDetails else {
            return
        }
        dismiss.toggle()
        moduleData.onSelect(details)
    }
    
    private func updateSections() {
        guard searchResult.isNotEmpty else {
            sections = []
            return
        }
        
        let today = Date()
        let dict = OrderedDictionary(
            grouping: searchResult,
            by: { dateFormatter.localizedString(for: $0.objectDetails.lastOpenedDate ?? today, relativeTo: today) }
        )
        
        sections = dict.map { (key, result) in
            listSectionData(title: key, result: result)
        }
    }
    
    private func updateObjectTypesModels(objectTypes: [ObjectType]) {
        objectTypesModelsToCreate = moduleData.type.objectTypesKeys.compactMap { [weak self] key in
            guard let self, let objectType = objectTypes.first(where: { $0.uniqueKey == key }),
                  let title = moduleData.type.title(for: key) else { return nil }
            return ObjectSearchCreationModel(
                title: title,
                onTap: { [weak self] in
                    self?.didSelectCreateObject(type: objectType)
                }
            )
        }
    }
    
    private func updateInitialStateIfNeeded() {
        guard isInitial else { return }
        isInitial = false
    }
    
    private func needDelay() -> Bool {
        !isInitial
    }
    
    private func listSectionData(title: String?, result: [SearchResultWithMeta]) -> ListSectionData<String?, SearchWithMetaModel> {
        ListSectionData(
            id: title ?? UUID().uuidString,
            data: title,
            rows: result.compactMap { result in
                searchWithMetaModelBuilder.buildModel(
                    with: result,
                    spaceId: moduleData.spaceId,
                    participantCanEdit: false
                )
            }
        )
    }
    
    private func buildSorts() -> [DataviewSort] {
        .builder {
            SearchHelper.sort(
                relation: BundledRelationKey.lastOpenedDate,
                type: .desc
            )
        }
    }
    
    private func didSelectCreateObject(type: ObjectType) {
        Task {
            let objectDetails = try await objectActionsService.createObject(
                name: "",
                typeUniqueKey: type.uniqueKey,
                shouldDeleteEmptyObject: true,
                shouldSelectType: false,
                shouldSelectTemplate: false,
                spaceId: moduleData.spaceId,
                origin: .none,
                templateId: type.defaultTemplateId
            )
            guard let data = objectDetails.screenData().editorScreenData else { return }
            output?.onOpenObject(data: data)
        }
    }
}
