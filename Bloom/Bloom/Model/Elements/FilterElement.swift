import Foundation

struct FilterElement: Codable, Equatable {
    /// 居住地
    var address: [String]
    /// 最大年齢
    var maxAge: Int?
    /// 最小年齢
    var minAge: Int?
    /// 距離
    var distance: Double?
    /// 趣味
    var hobbys: [String]
    /// 職業
    var professions: [String]
    /// グレード
    var grade: Int?
}

enum FilterType {
    case address
    case age
    case distance
    case hobbys
    case professions
    case grade
}
