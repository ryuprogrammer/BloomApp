import Foundation

extension Date {
    /// 時間を抽出: "HH:mm"
    func timeString() -> String {
        let dateFormatter = DateFormatter()
        // 時間の形式を指定
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    /// 日にちを抽出: "dd"
    func dayString() -> String {
        let dateFormatter = DateFormatter()
        // 時間の形式を指定
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }
}
