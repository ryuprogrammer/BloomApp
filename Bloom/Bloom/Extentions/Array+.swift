import Foundation

extension Array where Element == String {

    /// 画面の横幅に合わせて配列を整形
    func splitArrayByWidth(maxWidth: CGFloat) -> [[String]] {
        var result: [[String]] = [[]]
        var currentRowWidth: CGFloat = 0

        for item in self {
            let itemWidth = item.getWidthOfString()
            if currentRowWidth + itemWidth > maxWidth {
                currentRowWidth = 0
                result.append([])
            }
            result[result.count - 1].append(item)
            currentRowWidth += itemWidth + 10 // スペースの幅を考慮
        }

        return result
    }
}
