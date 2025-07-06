import SwiftUI

struct MultiDatePicker: View {
    @State private var selectedDates: Set<Date> = []
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Days of week header
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DateCell(
                            date: date,
                            isSelected: selectedDates.contains(date),
                            isStartDate: isStartDate(date),
                            isEndDate: isEndDate(date),
                            isInRange: isInRange(date)
                        ) {
                            toggleDate(date)
                        }
                    } else {
                        // Empty cell for padding
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
            .padding(.horizontal)
            
            // Selected dates info
            if !selectedDates.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected Dates (\(selectedDates.count))")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(selectedDates.sorted()), id: \.self) { date in
                                Text(formatDate(date))
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .navigationTitle("Multi-Date Picker")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper Methods
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }
        
        let firstOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
        
        var days: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add days of the month
        for day in 1...numberOfDaysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
    
    private func toggleDate(_ date: Date) {
        if selectedDates.contains(date) {
            selectedDates.remove(date)
        } else {
            selectedDates.insert(date)
        }
    }
    
    private func isStartDate(_ date: Date) -> Bool {
        guard let startDate = selectedDates.min() else { return false }
        return calendar.isDate(date, inSameDayAs: startDate)
    }
    
    private func isEndDate(_ date: Date) -> Bool {
        guard let endDate = selectedDates.max() else { return false }
        return calendar.isDate(date, inSameDayAs: endDate)
    }
    
    private func isInRange(_ date: Date) -> Bool {
        guard selectedDates.count > 1,
              let startDate = selectedDates.min(),
              let endDate = selectedDates.max() else { return false }
        
        return date >= startDate && date <= endDate
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct DateCell: View {
    let date: Date
    let isSelected: Bool
    let isStartDate: Bool
    let isEndDate: Bool
    let isInRange: Bool
    let action: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: action) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(textColor)
                .frame(width: 44, height: 44)
                .background(backgroundView)
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isInRange {
            return .blue
        } else {
            return .primary
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(backgroundOpacity))
        } else if isInRange {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.2))
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.clear)
        }
    }
    
    private var backgroundOpacity: Double {
        if isStartDate || isEndDate {
            return 1.0 // Higher opacity for start and end dates
        } else if isSelected {
            return 0.6 // Lower opacity for middle dates
        } else {
            return 0.0
        }
    }
}

// MARK: - Preview
struct MultiDatePickerView: View {
    var body: some View {
        NavigationView {
            MultiDatePicker()
        }
    }
}

#Preview {
    MultiDatePickerView()
}