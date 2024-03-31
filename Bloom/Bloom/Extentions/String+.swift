import Foundation
import UIKit

extension String {
    /// n文字目の文字を取得
    func forthText(forthNumber: Int) -> String? {
        if self.count >= forthNumber {
            let index = self.index(self.startIndex, offsetBy: forthNumber-1)
            let resultText = String(self[index])
            return resultText
        } else {
            return nil
        }
    }

    /// String型の数値をDate型に変換
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyyMMdd"

        // 無効な日付の場合はnilを返す
        guard let birthday = dateFormatter.date(from: self) else {
            return nil
        }

        let calendar = Calendar(identifier: .gregorian)
        let today = Date()

        // 18歳未満のチェック
        if let date18YearsAgo = calendar.date(byAdding: .year, value: -18, to: today), birthday > date18YearsAgo {
            return nil
        }

        // 60歳以上のチェック
        if let date60YearsAgo = calendar.date(byAdding: .year, value: -60, to: today), birthday <= date60YearsAgo {
            return nil
        }

        return birthday
    }

    /// 8桁の数値のString型を年齢に変換
    func toAge() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"

        guard let birthDate = dateFormatter.date(from: self) else {
            print("Invalid date format")
            return "年齢不詳"
        }

        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)

        guard let IntAge = ageComponents.year else { return "年齢不詳" }
        let StringAge = String(IntAge)

        return StringAge
    }

    /// 8桁の数値のString型を年月日に変換
    func toStringDate() -> String? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"

            // 8桁の数字をDate型に変換
            guard let date = dateFormatter.date(from: self) else {
                return nil
            }

            // 年月日のフォーマットを指定
            dateFormatter.dateFormat = "yyyy年MM月dd日"

            // 年月日を付け加えた文字列を返す
            return dateFormatter.string(from: date)
        }

    /// 文字列の横幅を計算
        func getWidthOfString() -> CGFloat {
            let font = UIFont.preferredFont(forTextStyle: .title3) // SwiftUIの.font(.title)に相当するUIFontを取得
            let attributes = [NSAttributedString.Key.font: font]
            let size = (self as NSString).size(withAttributes: attributes)
            return ceil(size.width) // 切り上げて返す
        }
}
