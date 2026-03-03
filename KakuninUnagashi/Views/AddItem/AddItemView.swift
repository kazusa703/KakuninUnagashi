import SwiftData
import SwiftUI

struct AddItemView: View {
    @Environment(\.appColors) private var colors
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CheckCategory.sortOrder) private var categories: [CheckCategory]

    @Bindable var viewModel: AddItemViewModel
    let notificationManager: NotificationManager

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Item name
                        fieldLabel(String(localized: "項目名", comment: "Item name"))
                        CustomTextField(
                            placeholder: String(localized: "例: エアコンフィルター掃除", comment: "Item name placeholder"),
                            text: $viewModel.name
                        )

                        // Category
                        fieldLabel(String(localized: "カテゴリ", comment: "Category"))
                        CategoryChipRow(
                            categories: categories,
                            selectedCategory: $viewModel.selectedCategory
                        )

                        // Schedule type
                        fieldLabel(String(localized: "スケジュール", comment: "Schedule"))
                        ScheduleTypePicker(
                            scheduleType: $viewModel.scheduleType,
                            intervalValue: $viewModel.intervalValue,
                            intervalUnit: $viewModel.intervalUnit,
                            specificDate: $viewModel.specificDate,
                            repeatYearly: $viewModel.repeatYearly,
                            dayOfWeek: $viewModel.dayOfWeek,
                            weekOrdinal: $viewModel.weekOrdinal
                        )

                        // Start date
                        fieldLabel(String(localized: "開始日", comment: "Start date"))
                        DatePicker(
                            "",
                            selection: $viewModel.startDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .tint(colors.primaryAccent)

                        // Notification time
                        fieldLabel(String(localized: "通知時刻（任意）", comment: "Notification time"))
                        HStack {
                            if viewModel.notificationTime != nil {
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: { viewModel.notificationTime ?? Date() },
                                        set: { viewModel.notificationTime = $0 }
                                    ),
                                    displayedComponents: .hourAndMinute
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .tint(colors.primaryAccent)

                                Button {
                                    viewModel.notificationTime = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(colors.secondaryText)
                                }
                            } else {
                                Button {
                                    var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                                    components.hour = 9
                                    components.minute = 0
                                    viewModel.notificationTime = Calendar.current.date(from: components)
                                } label: {
                                    HStack {
                                        Image(systemName: "bell")
                                        Text(String(localized: "通知を設定", comment: "Set notification"))
                                    }
                                    .font(.system(size: 15))
                                    .foregroundStyle(colors.primaryAccent)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(colors.primaryAccent.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.buttonCornerRadius))
                                }
                            }
                        }

                        // Memo
                        fieldLabel(String(localized: "メモ（任意）", comment: "Memo"))
                        CustomTextField(
                            placeholder: String(localized: "この確認項目についてのメモ", comment: "Memo placeholder"),
                            text: $viewModel.memo,
                            axis: .vertical
                        )
                        .frame(minHeight: 80, alignment: .topLeading)
                    }
                    .padding(.horizontal, DesignTokens.horizontalPadding)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }

                // Save button
                VStack(spacing: 0) {
                    SeparatorView()
                    PrimaryButton(
                        title: viewModel.isEditing
                            ? String(localized: "保存", comment: "Save button")
                            : String(localized: "項目を追加", comment: "Add item button")
                    ) {
                        Task {
                            await viewModel.save(context: modelContext, notificationManager: notificationManager)
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.isValid)
                    .opacity(viewModel.isValid ? 1.0 : 0.5)
                    .padding(.horizontal, DesignTokens.horizontalPadding)
                    .padding(.vertical, 12)
                }
                .background(colors.background)
            }
            .background(colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "キャンセル", comment: "Cancel button")) {
                        dismiss()
                    }
                    .foregroundStyle(colors.primaryAccent)
                }
                ToolbarItem(placement: .principal) {
                    Text(viewModel.isEditing
                        ? String(localized: "項目を編集", comment: "Edit item title")
                        : String(localized: "項目を追加", comment: "Add item title"))
                        .font(.system(size: 17, weight: .semibold))
                }
            }
        }
        .withAppTheme()
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(colors.secondaryText)
    }
}
