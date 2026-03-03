import SwiftData
import SwiftUI

struct HistoryView: View {
    @Environment(\.appColors) private var colors
    @Query private var items: [CheckItem]

    @Bindable var viewModel: HistoryViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Navigation header
            HStack {
                Text(String(localized: "履歴", comment: "History tab"))
                    .font(DesignTokens.navTitleFont)
                    .foregroundStyle(colors.primaryText)
                Spacer()
            }
            .padding(.horizontal, DesignTokens.horizontalPadding)
            .padding(.top, 8)

            // Month navigator
            MonthNavigatorView(
                monthYearString: viewModel.monthYearString,
                onPrevious: { viewModel.previousMonth() },
                onNext: { viewModel.nextMonth() }
            )
            .padding(.top, 8)

            // Content
            let confirmations = viewModel.filteredConfirmations(from: items)
            let grouped = viewModel.groupedByDate(confirmations)

            if grouped.isEmpty {
                EmptyStateView(
                    icon: "clock.arrow.circlepath",
                    title: String(localized: "まだ確認履歴がありません", comment: "No history"),
                    subtitle: nil
                )
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(grouped, id: \.date) { group in
                            // Date header
                            HStack {
                                Text(DateHelper.formatDateWithWeekday(group.date))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(colors.secondaryText)
                                Spacer()
                            }
                            .padding(.horizontal, DesignTokens.horizontalPadding)
                            .padding(.top, 16)
                            .padding(.bottom, 4)

                            SeparatorView()
                                .padding(.horizontal, DesignTokens.horizontalPadding)

                            CustomCardView {
                                ForEach(group.entries) { entry in
                                    HistoryEntryView(entry: entry)

                                    if entry.id != group.entries.last?.id {
                                        SeparatorView()
                                            .padding(.leading, DesignTokens.horizontalPadding + 30)
                                    }
                                }
                            }
                            .padding(.horizontal, DesignTokens.horizontalPadding)
                            .padding(.top, 4)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .background(colors.background)
    }
}
