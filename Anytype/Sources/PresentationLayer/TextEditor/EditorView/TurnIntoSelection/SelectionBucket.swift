import BlocksModels


struct SelectionBucket {
    var count = 0
    let turnIntoOptions: Set<BlockContentType>
}
