import Services

struct SubscriptionTogglerResult {
    let records: [ObjectDetails]
    let dependencies: [ObjectDetails]
    let total: Int
    let prevCount: Int
    let nextCount: Int
}
