import SwiftUI

struct PointIconView: View {
    let point: Int
    var body: some View {
        HStack(spacing: 3) {
            Text("＋" + String(point))
                .font(.system(size: 15))
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 1, y: 1)

            Image(systemName: "p.circle.fill")
                .foregroundStyle(Color.white)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 1, y: 1)

        }
        .padding(4)
        .background(Color.yellow)
        .clipShape(Capsule())
    }
}

struct PointIconView_Previews: PreviewProvider {
    static var previews: some View {
        PointIconView(point: 10)
    }
}
