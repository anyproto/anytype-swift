import Foundation

@MainActor
struct SimpleTableSlashMenuComparator {
    static func matchDefaultTable(slashAction: SlashAction, inputString: String) -> SlashActionFilterMatch? {
        let tableString = "table"

        guard inputString.contains(tableString) else {
            return SlashMenuComparator.match(slashAction: slashAction, string: inputString)
        }
        

        guard let rangeOfPath = inputString.range(of: tableString) else {
            return .init(action: slashAction, filterMatch: .fullTitle)
        }

        let nXmString = inputString.replacingCharacters(in: rangeOfPath, with: "")

        let numberParts = nXmString.split(separator: "x")

        guard let firstPart = numberParts[safe: 0],
              let firstNumber = Int(firstPart) else {
            return .init(action: slashAction, filterMatch: .titleSubstring)
        }

        let validFirstNumber = validRangeValue(number: firstNumber)

        guard let secondPart = numberParts[safe: 1],
              let secondNumber = Int(secondPart) else {
            return .init(action: .other(.table(rowsCount: validFirstNumber, columnsCount: 3)), filterMatch: .fullTitle)
        }

        return .init(
            action: .other(.table(rowsCount: validFirstNumber, columnsCount: validRangeValue(number: secondNumber))),
            filterMatch: .fullTitle
        )
    }

    private static func validRangeValue(number: Int) -> Int {
        max(1, min(25, number))
    }
}
