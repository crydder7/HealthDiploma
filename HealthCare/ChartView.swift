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

    var body: some View {
        VStack{
            DatePicker(selection: $date, displayedComponents: [.date]) {
                Label("Date", systemImage: "calendar")
            }
            .datePickerStyle(.automatic)
            
            Text("Hello, \(patient.user.name)!")
            
            
            
            Chart(forecastedData) { measure in
                LineMark(x: .value("time", Date(timeIntervalSince1970: TimeInterval(measure.timestamp))) , y: .value("glucose", Double(measure.glucose.value)))
                    .symbol(.circle)
                    .foregroundStyle(.red)
            }
            .chartXAxis(.visible)
            .chartYAxis(.visible)
            .chartScrollableAxes(.horizontal)
            .padding()
            .border(.black, width: 2.0)
            
            
            HStack{
                Button {
                    Task{
                        try await patient.getTodayData(date: date)
                        chartData = patient.measurements
                        forecastedData = chartData
                    }
                    
                } label: {
                    Label("Get measurements", systemImage: "chart.line.uptrend.xyaxis")
                }
                .padding()
                .glassEffect()
                
                Button {
                    //TODO: - Integrate all funcs to .forecast function
                    forecastingViewModel = ModelPredictViewModel(user: patient.user, measurements: chartData)
                    forecastingViewModel!.createLags()
                    forecastingViewModel!.createVelocity()
                    forecastingViewModel!.createAcceleration()
                    forecastingViewModel!.createMeanRecent()
                    forecastedData.append(forecastingViewModel!.forecast(minutes: 5))
                } label: {
                    Text("Generate forecast")
                }
                .padding()
                .glassEffect()
            }
            
        }
        .padding()
    }
}

//#Preview {
//    MailView()
//}
