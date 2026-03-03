import PhotosUI
import SwiftUI

struct ConfirmationInlineView: View {
    @Environment(\.appColors) private var colors
    let item: CheckItem
    @Binding var memo: String
    @Binding var photoData: Data?
    let onDismiss: () -> Void
    let onFinalize: () -> Void

    @State private var showMemoField = false
    @State private var showPhotoPicker = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var checkScale: CGFloat = 0

    var body: some View {
        VStack(spacing: 12) {
            // Success indicator
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(colors.confirmedGreen)
                    .scaleEffect(checkScale)
                Text(String(localized: "確認しました！", comment: "Confirmed"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(colors.confirmedGreen)
            }

            // Action buttons
            HStack(spacing: 12) {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label(String(localized: "写真を追加", comment: "Add photo"), systemImage: "camera")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(colors.primaryAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(colors.primaryAccent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.buttonCornerRadius))
                }

                Button {
                    withAnimation { showMemoField.toggle() }
                } label: {
                    Label(String(localized: "メモを追加", comment: "Add memo"), systemImage: "note.text")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(colors.primaryAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(colors.primaryAccent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.buttonCornerRadius))
                }
            }

            // Photo preview
            if let photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Memo field
            if showMemoField {
                CustomTextField(
                    placeholder: String(localized: "メモを入力", comment: "Memo placeholder"),
                    text: $memo,
                    axis: .vertical
                )
            }

            // Next schedule info
            let nextDate = ScheduleCalculator.nextDueDate(for: item)
            Text(String(localized: "次回: \(DateHelper.formatDateWithWeekday(nextDate))", comment: "Next due date"))
                .font(DesignTokens.captionFont)
                .foregroundStyle(colors.secondaryText)

            // Finalize button
            Button(action: onFinalize) {
                Text("OK")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(colors.primaryAccent)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.buttonCornerRadius))
            }
        }
        .padding(DesignTokens.horizontalPadding)
        .onAppear {
            withAnimation(DesignTokens.springAnimation) {
                checkScale = 1.0
            }
        }
        .onChange(of: selectedPhoto) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        // Resize image before saving
                        if let image = UIImage(data: data),
                           let resized = resizeImage(image, maxDimension: 1024),
                           let jpeg = resized.jpegData(compressionQuality: 0.7)
                        {
                            photoData = jpeg
                        }
                    }
                }
            }
        }
        .sensoryFeedback(.success, trigger: checkScale)
    }

    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage? {
        let size = image.size
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        guard ratio < 1 else { return image }
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
