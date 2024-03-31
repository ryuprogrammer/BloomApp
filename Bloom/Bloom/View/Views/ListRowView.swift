import SwiftUI

struct ListRowView: View {
    var viewType: ViewType
    var isVip: Bool?
    var image: String
    var title: String?
    var detail: String?
    let iconSize = UIScreen.main.bounds.width / 20

    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(Color.gray)

            if let title = title {
                Text(title)
                    .foregroundColor(.gray)

                if let isVip, isVip {
                    VipTicketView()
                }

                Spacer()
            }
            if let detail = detail {
                Text(detail)
                    .foregroundStyle(Color.pink)
            } else {
                if viewType == .FilterView {
                    Text("こだわらない")
                } else if viewType == .MyPageView {
                    PointIconView(point: 10)
                }
            }
        }
    }
}

enum ViewType {
    case MyPageView
    case FilterView
}

#Preview {
    ListRowView(
        viewType: .FilterView,
        isVip: true,
        image: "birthday.cake",
        title: "趣味",
        detail: "ボードゲーム"
    )
}
