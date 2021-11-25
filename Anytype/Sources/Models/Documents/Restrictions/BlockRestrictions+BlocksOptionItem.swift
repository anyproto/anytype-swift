extension Array where Element == BlockRestrictions {
    var mergedOptions: [BlocksOptionItem] {
        var options = Set(BlocksOptionItem.allCases)

        forEach { element in
            if !element.canDeleteOrDuplicate {
                options.remove(.delete)
                options.remove(.duplicate)
            }

            if !element.canCreateBlockBelowOnEnter {
                options.remove(.addBlockBelow)
            }

            if !element.canApplyStyle(.smartblock(.page)) {
                options.remove(.turnInto)
            }
        }

        return Array<BlocksOptionItem>(options).sorted()
    }
}
