import SwiftUI

struct ProfessionEditView: View {
    let professionEditViewModel = ProfessionEditViewModel()
    @Binding var profession: String?
    @State var showProfession: String = ""
    @State var professionData: [[String]] = [[]]
    @State var isHobbyValid: Bool = true
    let barHeight = UIScreen.main.bounds.height / 10

    @Environment(\.dismiss) private var dismiss
    let maxWidth: CGFloat = UIScreen.main.bounds.width - 90 // マージンを取る

    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                Spacer()
                    .frame(height: barHeight)

                VStack(alignment: .leading) {
                    ForEach(professionData, id: \.self) { row in
                        HStack(spacing: 3) {
                            ForEach(row, id: \.self) { item in
                                if showProfession == item {
                                    Text(item)
                                        .font(.title2)
                                        .foregroundStyle(Color.pink.opacity(0.8))
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 8)
                                        .background {
                                            Capsule().stroke(Color.pink.opacity(0.8), lineWidth: 5)
                                        }
                                        .padding(5)
                                        .lineLimit(1)
                                        .fixedSize()
                                } else {
                                    Text(item)
                                        .font(.title3)
                                        .foregroundStyle(.gray)
                                        .padding(5)
                                        .padding(.horizontal, 8)
                                        .lineLimit(1)
                                        .fixedSize()
                                        .onTapGesture {
                                            withAnimation {
                                                showProfession = item
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
                .padding(.top)

                Spacer()
                    .frame(height: 130)
            }

            VStack {
                VStack {
                    Text("職業を選択してください")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .padding(.top)

                    if showProfession == "" {
                        Text("まだ選択されてません")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)
                            .padding(5)
                    } else {
                        Text(showProfession)
                            .font(.callout)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.pink.opacity(0.8))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 8)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.bottom, 10)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: barHeight)
                .background(Color.pink.opacity(0.8))

                Spacer()

                ButtonView(
                    title: "職業を選択",
                    imageName: "mappin.and.ellipse",
                    isValid: $isHobbyValid,
                    action: {
                        profession = showProfession
                        dismiss()
                    }
                )
            }
        }
        .onAppear {
            professionData = professionEditViewModel.fetchProfessionData().splitArrayByWidth(maxWidth: maxWidth)
            if let profession {
                showProfession = profession
            }
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State var profession: String? = "マジシャン"
        var body: some View {
            ProfessionEditView(profession: $profession)
        }
    }

    return PreviewView()
}
