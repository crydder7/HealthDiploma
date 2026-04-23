//import SwiftUI
//import Charts
//
//// Модель данных для измерения глюкозы
//struct GlucoseMeasurement: Identifiable {
//    let id = UUID()
//    let timestamp: Date
//    let value: Double // мг/дл
//    let timeOfDay: String
//    
//    init(hour: Int, minute: Int, value: Double) {
//        let calendar = Calendar.current
//        var components = DateComponents()
//        components.hour = hour
//        components.minute = minute
//        self.timestamp = calendar.date(from: components) ?? Date()
//        self.value = value
//        self.timeOfDay = String(format: "%02d:%02d", hour, minute)
//    }
//}
//
//// Модель пациента
//struct PatientStruct: Identifiable, Hashable {
//    let id = UUID()
//    let fullName: String
//    let birthDate: Date
//    let patientID: String
//    
//    static let samplePatients = [
//        PatientStruct(fullName: "Иванов Алексей Петрович", birthDate: Date().addingTimeInterval(-60*86400*365*45), patientID: "P001"),
//        PatientStruct(fullName: "Петрова Мария Сергеевна", birthDate: Date().addingTimeInterval(-60*86400*365*38), patientID: "P002"),
//        PatientStruct(fullName: "Сидоров Дмитрий Иванович", birthDate: Date().addingTimeInterval(-60*86400*365*52), patientID: "P003")
//    ]
//}
//
//// GlassEffect контейнер для iOS 26
//struct GlassEffectContainer<Content: View>: View {
//    let content: Content
//    
//    init(@ViewBuilder content: () -> Content) {
//        self.content = content()
//    }
//    
//    var body: some View {
//        content
//            .background(.ultraThinMaterial)
//            .cornerRadius(16)
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(.white.opacity(0.2), lineWidth: 1)
//            )
//            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
//    }
//}
//
//// Основная View
//struct GlucoseAnalysisView: View {
//    @State private var selectedPatient: PatientStruct = PatientStruct.samplePatients[0]
//    @State private var selectedDate: Date = Date()
//    @State private var measurements: [GlucoseMeasurement] = []
//    @State private var isExpanded: Bool = false
//    
//    // Градиенты для дизайна
//    private let backgroundGradient = LinearGradient(
//        colors: [Color(.systemBlue).opacity(0.1), Color(.systemPurple).opacity(0.05)],
//        startPoint: .topLeading,
//        endPoint: .bottomTrailing
//    )
//    
//    // Статистические показатели
//    private var averageGlucose: Double {
//        guard !measurements.isEmpty else { return 0 }
//        return measurements.map { $0.value }.reduce(0, +) / Double(measurements.count)
//    }
//    
//    private var medianGlucose: Double {
//        guard !measurements.isEmpty else { return 0 }
//        let sortedValues = measurements.map { $0.value }.sorted()
//        let middle = sortedValues.count / 2
//        if sortedValues.count % 2 == 0 {
//            return (sortedValues[middle - 1] + sortedValues[middle]) / 2
//        } else {
//            return sortedValues[middle]
//        }
//    }
//    
//    private var trend: String {
//        guard measurements.count >= 2 else { return "Недостаточно данных" }
//        
//        let firstHalf = Array(measurements.prefix(measurements.count / 2))
//        let secondHalf = Array(measurements.suffix(measurements.count / 2))
//        
//        let firstAvg = firstHalf.map { $0.value }.reduce(0, +) / Double(firstHalf.count)
//        let secondAvg = secondHalf.map { $0.value }.reduce(0, +) / Double(secondHalf.count)
//        
//        let difference = secondAvg - firstAvg
//        
//        switch difference {
//        case ..<(-10):
//            return "📉 Сильное снижение"
//        case -10..<(-5):
//            return "↘️ Умеренное снижение"
//        case -5..<5:
//            return "➡️ Стабильно"
//        case 5..<10:
//            return "↗️ Умеренный рост"
//        default:
//            return "📈 Сильный рост"
//        }
//    }
//    
//    private var dateFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .none
//        formatter.locale = Locale(identifier: "ru_RU")
//        return formatter
//    }
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // Фоновый градиент
//                backgroundGradient
//                    .ignoresSafeArea()
//                
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 20) {
//                        headerSection
//                        
//                        // Выбор пациента и даты
//                        controlSection
//                        
//                        // Основная статистика
//                        quickStatsSection
//                        
//                        // График глюкозы
//                        glucoseChartSection
//                        
//                        // Детальная статистика
//                        detailedStatsSection
//                        
//                        // Таблица измерений
//                        measurementsTableSection
//                    }
//                    .padding()
//                }
//            }
//            .navigationBarHidden(true)
//            .onAppear {
//                generateMeasurements()
//            }
//            .onChange(of: selectedPatient) { _ in
//                generateMeasurements()
//            }
//            .onChange(of: selectedDate) { _ in
//                generateMeasurements()
//            }
//        }
//    }
//    
//    // Хедер с названием
//    private var headerSection: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Анализ глюкозы")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .foregroundColor(.primary)
//                
//                Text("Мониторинг показателей")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            
//            Spacer()
//            
//            // Иконка пользователя
//            Image(systemName: "person.circle.fill")
//                .font(.title2)
//                .foregroundColor(.blue)
//        }
//        .padding(.top, 20)
//    }
//    
//    // Секция выбора пациента и даты
//    private var controlSection: some View {
//        GlassEffectContainer {
//            VStack(alignment: .leading, spacing: 16) {
//                HStack {
//                    Image(systemName: "slider.horizontal.3")
//                        .foregroundColor(.blue)
//                    Text("Параметры анализа")
//                        .font(.headline)
//                        .foregroundColor(.primary)
//                    Spacer()
//                }
//                
//                VStack(spacing: 12) {
//                    HStack {
//                        Image(systemName: "person.fill")
//                            .foregroundColor(.secondary)
//                            .frame(width: 20)
//                        Text("Пациент")
//                            .foregroundColor(.secondary)
//                        Spacer()
//                        Picker("", selection: $selectedPatient) {
//                            ForEach(PatientStruct.samplePatients) { patient in
//                                Text(patient.fullName.components(separatedBy: " ")[0]).tag(patient)
//                            }
//                        }
//                        .pickerStyle(MenuPickerStyle())
//                        .accentColor(.blue)
//                    }
//                    
//                    Divider()
//                    
//                    HStack {
//                        Image(systemName: "calendar")
//                            .foregroundColor(.secondary)
//                            .frame(width: 20)
//                        Text("Дата")
//                            .foregroundColor(.secondary)
//                        Spacer()
//                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
//                            .datePickerStyle(CompactDatePickerStyle())
//                            .accentColor(.blue)
//                    }
//                }
//            }
//            .padding(20)
//        }
//    }
//    
//    // Быстрая статистика
//    private var quickStatsSection: some View {
//        LazyVGrid(columns: [
//            GridItem(.flexible()),
//            GridItem(.flexible())
//        ], spacing: 16) {
//            StatCard(
//                title: "Среднее",
//                value: "\(Int(averageGlucose))",
//                subtitle: "мг/дл",
//                color: .blue,
//                icon: "number.circle.fill"
//            )
//            
//            StatCard(
//                title: "Тренд",
//                value: trend.components(separatedBy: " ").first ?? "",
//                subtitle: trend.components(separatedBy: " ").dropFirst().joined(separator: " "),
//                color: trendColor,
//                icon: "chart.line.uptrend.xyaxis"
//            )
//        }
//    }
//    
//    private var trendColor: Color {
//        switch trend {
//        case let t where t.contains("снижение"):
//            return .green
//        case let t where t.contains("рост"):
//            return .orange
//        default:
//            return .blue
//        }
//    }
//    
//    // Секция графика
//    private var glucoseChartSection: some View {
//        GlassEffectContainer {
//            VStack(alignment: .leading, spacing: 16) {
//                HStack {
//                    Image(systemName: "chart.xyaxis.line")
//                        .foregroundColor(.blue)
//                    Text("Динамика глюкозы")
//                        .font(.headline)
//                        .foregroundColor(.primary)
//                    Spacer()
//                    
//                    Button(action: { isExpanded.toggle() }) {
//                        Image(systemName: isExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
//                            .foregroundColor(.blue)
//                    }
//                }
//                
//                if measurements.isEmpty {
//                    Text("Нет данных для отображения")
//                        .foregroundColor(.secondary)
//                        .frame(height: 200)
//                        .frame(maxWidth: .infinity)
//                } else {
//                    Chart(measurements) { measurement in
//                        LineMark(
//                            x: .value("Время", measurement.timeOfDay),
//                            y: .value("Глюкоза", measurement.value)
//                        )
//                        .foregroundStyle(glucoseGradient(value: measurement.value))
//                        .lineStyle(StrokeStyle(lineWidth: 3))
//                        
//                        AreaMark(
//                            x: .value("Время", measurement.timeOfDay),
//                            y: .value("Глюкоза", measurement.value)
//                        )
//                        .foregroundStyle(glucoseGradient(value: measurement.value).opacity(0.1))
//                        
//                        PointMark(
//                            x: .value("Время", measurement.timeOfDay),
//                            y: .value("Глюкоза", measurement.value)
//                        )
//                        .foregroundStyle(glucoseColor(value: measurement.value))
//                        .annotation(position: .top) {
//                            Text("\(Int(measurement.value))")
//                                .font(.system(size: 10, weight: .medium))
//                                .foregroundColor(.primary)
//                                .padding(4)
//                                .background(.ultraThinMaterial)
//                                .cornerRadius(4)
//                        }
//                    }
//                    .frame(height: isExpanded ? 300 : 200)
//                    .chartYScale(domain: 60...200)
//                    .chartYAxis {
//                        AxisMarks(position: .leading)
//                    }
//                    .chartXAxis {
//                        AxisMarks(preset: .aligned)
//                    }
//                }
//            }
//            .padding(20)
//        }
//    }
//    
//    // Детальная статистика
//    private var detailedStatsSection: some View {
//        GlassEffectContainer {
//            VStack(alignment: .leading, spacing: 16) {
//                HStack {
//                    Image(systemName: "chart.bar.fill")
//                        .foregroundColor(.blue)
//                    Text("Детальная статистика")
//                        .font(.headline)
//                        .foregroundColor(.primary)
//                    Spacer()
//                }
//                
//                if measurements.isEmpty {
//                    Text("Нет данных для расчета")
//                        .foregroundColor(.secondary)
//                } else {
//                    LazyVGrid(columns: [
//                        GridItem(.flexible()),
//                        GridItem(.flexible())
//                    ], spacing: 12) {
//                        DetailStatItem(
//                            title: "Медиана",
//                            value: "\(Int(medianGlucose)) мг/дл",
//                            icon: "divide.circle.fill",
//                            color: .green
//                        )
//                        
//                        DetailStatItem(
//                            title: "Кол-во измерений",
//                            value: "\(measurements.count)",
//                            icon: "number.circle.fill",
//                            color: .purple
//                        )
//                        
//                        DetailStatItem(
//                            title: "Минимум",
//                            value: "\(Int(measurements.map { $0.value }.min() ?? 0)) мг/дл",
//                            icon: "arrow.down.circle.fill",
//                            color: .blue
//                        )
//                        
//                        DetailStatItem(
//                            title: "Максимум",
//                            value: "\(Int(measurements.map { $0.value }.max() ?? 0)) мг/дл",
//                            icon: "arrow.up.circle.fill",
//                            color: .orange
//                        )
//                    }
//                }
//            }
//            .padding(20)
//        }
//    }
//    
//    // Секция таблицы измерений
//    private var measurementsTableSection: some View {
//        GlassEffectContainer {
//            VStack(alignment: .leading, spacing: 16) {
//                HStack {
//                    Image(systemName: "list.bullet")
//                        .foregroundColor(.blue)
//                    Text("История измерений")
//                        .font(.headline)
//                        .foregroundColor(.primary)
//                    Spacer()
//                    
//                    Text("Всего: \(measurements.count)")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//                
//                if measurements.isEmpty {
//                    Text("Нет данных измерений")
//                        .foregroundColor(.secondary)
//                } else {
//                    LazyVStack(spacing: 8) {
//                        ForEach(measurements) { measurement in
//                            MeasurementRow(measurement: measurement)
//                                .padding(.horizontal, 4)
//                        }
//                    }
//                }
//            }
//            .padding(20)
//        }
//    }
//    
//    // Вспомогательные функции для цветов
//    private func glucoseColor(value: Double) -> Color {
//        switch value {
//        case ..<70:
//            return .red
//        case 70..<140:
//            return .green
//        case 140..<180:
//            return .orange
//        default:
//            return .red
//        }
//    }
//    
//    private func glucoseGradient(value: Double) -> LinearGradient {
//        let color = glucoseColor(value: value)
//        return LinearGradient(
//            colors: [color, color.opacity(0.7)],
//            startPoint: .top,
//            endPoint: .bottom
//        )
//    }
//    
//    // Генерация тестовых данных
//    private func generateMeasurements() {
//        let measurementCount = Int.random(in: 5...8)
//        var newMeasurements: [GlucoseMeasurement] = []
//        
//        let baseGlucose = Double.random(in: 90...160)
//        
//        for i in 0..<measurementCount {
//            let hour = 7 + (i * 2)
//            let minute = Int.random(in: 0...59)
//            
//            let timeFactor: Double
//            switch hour {
//            case 7...9:
//                timeFactor = Double.random(in: 0.9...1.3)
//            case 11...13:
//                timeFactor = Double.random(in: 1.0...1.5)
//            case 15...17:
//                timeFactor = Double.random(in: 0.8...1.2)
//            case 19...21:
//                timeFactor = Double.random(in: 0.9...1.1)
//            default:
//                timeFactor = 1.0
//            }
//            
//            let glucoseValue = baseGlucose * timeFactor + Double.random(in: -15...15)
//            let measurement = GlucoseMeasurement(
//                hour: hour,
//                minute: minute,
//                value: max(70, min(200, glucoseValue))
//            )
//            newMeasurements.append(measurement)
//        }
//        
//        measurements = newMeasurements.sorted { $0.timestamp < $1.timestamp }
//    }
//}
//
//// Компонент для статистической карточки
//struct StatCard: View {
//    let title: String
//    let value: String
//    let subtitle: String
//    let color: Color
//    let icon: String
//    
//    var body: some View {
//        GlassEffectContainer {
//            VStack(alignment: .leading, spacing: 8) {
//                HStack {
//                    Image(systemName: icon)
//                        .font(.title3)
//                        .foregroundColor(color)
//                    Spacer()
//                }
//                
//                Text(value)
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundColor(.primary)
//                
//                Text(title)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                
//                Text(subtitle)
//                    .font(.system(size: 12, weight: .medium))
//                    .foregroundColor(color)
//            }
//            .padding(16)
//            .frame(maxWidth: .infinity, alignment: .leading)
//        }
//    }
//}
//
//// Компонент для детальной статистики
//struct DetailStatItem: View {
//    let title: String
//    let value: String
//    let icon: String
//    let color: Color
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            Image(systemName: icon)
//                .font(.body)
//                .foregroundColor(color)
//                .frame(width: 20)
//            
//            VStack(alignment: .leading, spacing: 2) {
//                Text(title)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                Text(value)
//                    .font(.system(size: 14, weight: .semibold))
//                    .foregroundColor(.primary)
//            }
//            
//            Spacer()
//        }
//        .padding(12)
//        .background(color.opacity(0.1))
//        .cornerRadius(12)
//    }
//}
//
//// Строка измерения
//struct MeasurementRow: View {
//    let measurement: GlucoseMeasurement
//    
//    private var glucoseColor: Color {
//        switch measurement.value {
//        case ..<70:
//            return .red
//        case 70..<140:
//            return .green
//        case 140..<180:
//            return .orange
//        default:
//            return .red
//        }
//    }
//    
//    private var glucoseStatus: String {
//        switch measurement.value {
//        case ..<70:
//            return "Низкий"
//        case 70..<140:
//            return "Норма"
//        case 140..<180:
//            return "Высокий"
//        default:
//            return "Очень высокий"
//        }
//    }
//    
//    var body: some View {
//        HStack {
//            HStack(spacing: 12) {
//                Circle()
//                    .fill(glucoseColor)
//                    .frame(width: 8, height: 8)
//                
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(measurement.timeOfDay)
//                        .font(.subheadline)
//                        .fontWeight(.medium)
//                        .foregroundColor(.primary)
//                    Text(glucoseStatus)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//            }
//            
//            Spacer()
//            
//            Text("\(Int(measurement.value)) мг/дл")
//                .font(.system(size: 16, weight: .semibold))
//                .foregroundColor(glucoseColor)
//        }
//        .padding(12)
//        .background(.ultraThinMaterial)
//        .cornerRadius(12)
//    }
//}
//
//// Предварительный просмотр
//struct GlucoseAnalysisView_Previews: PreviewProvider {
//    static var previews: some View {
//        GlucoseAnalysisView()
//    }
//}
