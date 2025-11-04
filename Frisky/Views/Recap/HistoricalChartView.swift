import SwiftUI
import Charts


struct HistoricalChartView: View {
    @ObservedObject private var healthKitManager = HealthKitManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedMetric: MetricType = .steps
    
    @State private var chartData: [DailyMetric] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            backgroundColor
            
            VStack(spacing: 0) {
                topBar
                
                calendarWeekView
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                metricSelector
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                if isLoading {
                    Spacer()
                    ProgressView("Loading data...")
                        .foregroundColor(.white)
                    Spacer()
                } else {
                    chartView
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                }
                
                Spacer()
            }
        }
        .onAppear {
            Task {
                await loadHistoricalData()
            }
        }
    }
    
    var topBar: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
            }
            
            Spacer()
        }
    }
    
    var calendarWeekView: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(formattedTodayDate)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { day in
                    VStack(spacing: 8) {
                        Text(day.dayLetter)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("\(day.dayNumber)")
                            .font(.body)
                            .fontWeight(day.isToday ? .bold : .regular)
                            .foregroundColor(day.isToday ? .black : .white)
                            .frame(width: 40, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(day.isToday ? Color.white : Color.clear)
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    var metricSelector: some View {
        Menu {
            ForEach(MetricType.allCases, id: \.self) { metric in
                Button(action: {
                    selectedMetric = metric
                    Task {
                        await loadHistoricalData()
                    }
                }) {
                    HStack {
                        Image(systemName: metric.icon)
                        Text(metric.title)
                        if selectedMetric == metric {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(selectedMetric.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Image(systemName: "chevron.down")
                    .font(.title3)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.2))
            )
        }
    }
    
    var chartView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Chart(chartData) { data in
                LineMark(
                    x: .value("Day", data.date, unit: .day),
                    y: .value(selectedMetric.title, data.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.cyan, Color.blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                PointMark(
                    x: .value("Day", data.date, unit: .day),
                    y: .value(selectedMetric.title, data.value)
                )
                .foregroundStyle(Color.cyan)
                .symbolSize(80)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(formatDateLabel(date))
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.white.opacity(0.2))
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .frame(height: 300)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
        var backgroundColor: some View {
        LinearGradient(
            colors: [
                Color(red: 0.6, green: 0.6, blue: 0.9),
                Color(red: 0.7, green: 0.7, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    @MainActor
    func loadHistoricalData() async {
        isLoading = true
        chartData = []
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get past 7 days of data
        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else {
                continue
            }
            
            do {
                let value: Double
                
                switch selectedMetric {
                case .steps:
                    value = Double(try await healthKitManager.fetchSteps(for: date))
                case .sleep:
                    value = try await healthKitManager.fetchSleepHours(for: date)
                case .exercise:
                    value = try await healthKitManager.fetchExerciseMinutes(for: date)
                case .heartRate:
                    value = Double(try await healthKitManager.fetchAverageHeartRate(for: date))
                }
                
                chartData.append(DailyMetric(date: date, value: value))
                
            } catch {
                print("Error fetching data for \(date): \(error)")
                chartData.append(DailyMetric(date: date, value: 0))
            }
        }
        
        isLoading = false
    }
    
    
    var formattedTodayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
    
    var weekDays: [WeekDay] {
        let calendar = Calendar.current
        let today = Date()
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return []
        }
        
        var days: [WeekDay] = []
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: weekInterval.start) {
                let dayLetter = calendar.weekdaySymbols[calendar.component(.weekday, from: date) - 1].prefix(1).uppercased()
                let dayNumber = calendar.component(.day, from: date)
                let isToday = calendar.isDateInToday(date)
                
                days.append(WeekDay(
                    dayLetter: String(dayLetter),
                    dayNumber: dayNumber,
                    isToday: isToday
                ))
            }
        }
        
        return days
    }
    
    func formatDateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

struct WeekDay: Hashable {
    let dayLetter: String
    let dayNumber: Int
    let isToday: Bool
}

struct DailyMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

enum MetricType: String, CaseIterable {
    case steps = "Steps"
    case sleep = "Sleep"
    case exercise = "Exercise"
    case heartRate = "Heart Rate"
    
    var title: String { rawValue }
    
    var icon: String {
        switch self {
        case .steps: return "figure.walk"
        case .sleep: return "bed.double.fill"
        case .exercise: return "flame.fill"
        case .heartRate: return "heart.fill"
        }
    }
}

#Preview {
    HistoricalChartView()
}
