import Foundation

extension FilterElement {
    /// FilterTypeを指定して、文字列にする
    func toString(filterType: FilterType) -> String? {
        var result: String? = nil
        let filter = self

        switch filterType {
        case .address:
            if !filter.address.isEmpty {
                result = filter.address.joined(separator: "・")
            }
        case .age:
            if let maxAge = filter.maxAge,
                  let minAge = filter.minAge {
                    result = String(minAge) + "〜" + String(maxAge)
            }
        case .distance:
            if let distance = filter.distance {
                result = String(Int(distance)) + "km"
            }
        case .hobbys:
            if !filter.hobbys.isEmpty {
                result = filter.hobbys.joined(separator: "・")
            }
        case .professions:
            if !filter.professions.isEmpty {
                result = filter.professions.joined(separator: "・")
            }
        case .grade:
            if let grade = filter.grade {
                result = "ランク" + String(grade) + "以上"
            }
        }

        return result
    }
}
