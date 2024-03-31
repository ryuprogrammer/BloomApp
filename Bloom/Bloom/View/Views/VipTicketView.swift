import SwiftUI

struct VipTicketView: View {
    var body: some View {
        Text("VIP")
            .font(.system(size: 15))
            .fontWeight(.bold)
            .foregroundStyle(Color.white)
            .frame(width: 25, height: 7)
            .padding(9)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.vipStart, Color.vipEnd]), startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

#Preview {
    VipTicketView()
}
