//
//  MailView.swift
//  HealthCare
//
//  Created by lonely. on 2/21/26.
//

import SwiftUI
import Charts

struct ChartView: View {
    @ObservedObject var patient: PatientViewModel
    @State var date: Date = Date()
    @State var chartData: [RawMeasurement] = []
    @State var forecastedData: [RawMeasurement] = []
    //TODO: - STATEOBJECT???
    @State var forecastingViewModel: ModelPredictViewModel?
    @State var showAlert: Bool = false
    @State var alerText: String = ""
    @EnvironmentObject var docInfo: DoctorInfo

    var body: some View {
        VStack{
            DatePicker(selection: $date, displayedComponents: [.date]) {
                Label("Date", systemImage: "calendar")
            }
            .datePickerStyle(.automatic)
            
            Chart(forecastedData) { measure in
                LineMark(
                    x: .value("time", Date(timeIntervalSince1970: TimeInterval(measure.timestamp))),
                    y: .value("glucose", Double(measure.glucose.value))
                )
                .foregroundStyle(by: .value("Segment", measure.isGenerated))
                .lineStyle(by: .value("Segment", measure.isGenerated))
                
                PointMark(
                    x: .value("time", Date(timeIntervalSince1970: TimeInterval(measure.timestamp))),
                    y: .value("glucose", Double(measure.glucose.value))
                )
                .foregroundStyle(by: .value("Segment", measure.isGenerated))
            }
            .chartForegroundStyleScale([
                "actual":    .red,
                "predicted": .blue
            ])
            .chartLineStyleScale([
                "actual":    StrokeStyle(lineWidth: 2),
                "predicted": StrokeStyle(lineWidth: 2, dash: [5, 3])
            ])
            .chartYScale(domain: 0...15)
            .chartXScale(domain: forecastedData.isEmpty ? Date(timeIntervalSince1970: 0)...Date(timeIntervalSince1970: 670) : Date(timeIntervalSince1970: TimeInterval(forecastedData[0].timestamp))...Date(timeIntervalSince1970: TimeInterval(forecastedData.last!.timestamp)))
            .chartYAxis {
                AxisMarks(values: .stride(by: 1.0)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .minute, count: 30)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.hour().minute())
                }
            }
            .chartScrollableAxes(.horizontal)
            .padding()
            
            HStack{
                Button {
                    Task{
                        do{
                            try await patient.getTodayData(date: date)
                            chartData = patient.measurements
                            forecastedData = chartData
                        } catch {
                            showAlert = true
                            alerText = error.localizedDescription
                        }
                    }
                    
                } label: {
                    Label("Get measurements", systemImage: "chart.line.uptrend.xyaxis")
                }
                .padding()
                .glassEffect()
//                .alert(isPresented: $showAlert) {
//                    Alert(title: Text(alerText))
//                }
                
                Button {
                    //TODO: - Integrate all funcs to .forecast function
                    forecastingViewModel = ModelPredictViewModel(userId: patient.user.id, measurements: chartData)
                    Task{
                        do {
                            try await forecastedData.append(contentsOf: forecastingViewModel!.forecast(minutes: 5))
                        }
                        catch {
                            showAlert = true
                            alerText = "Нет данных для предсказания"
                        }
                    }
                } label: {
                    Label("Generate forecast", systemImage: "play.fill")
                }
                .padding()
                .glassEffect()
            }
            
        }
        .padding()
        .task({
            do {
                try await patient.getDocInfo(docInfo)
            } catch {
                showAlert = true
                alerText = error.localizedDescription
            }
        })
        .alert(isPresented: $showAlert){
            Alert(title: Text("Ошибка"), message: Text(alerText))
        }
    }
}

//#Preview {
//    MailView()
//}
