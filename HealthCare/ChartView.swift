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

    var body: some View {
        VStack{
            DatePicker(selection: $date, displayedComponents: [.date]) {
                Label("Date", systemImage: "calendar")
            }
            .datePickerStyle(.automatic)
            
            Text("Hello, \(patient.user.name)!")
            
            
            
            Chart(chartData) { measure in
                LineMark(x: .value("time", Date(timeIntervalSince1970: TimeInterval(measure.timestamp))) , y: .value("glucose", Double(measure.glucose.value)))
            }
            
            Button {
                Task{
                    try await patient.getTodayData(date: date)
                    chartData = patient.measurements
                    print(chartData)
                }
                
            } label: {
                Text("Get measurements")
            }
            .glassEffect()
            .padding()
        }
        .padding()
    }
}

//#Preview {
//    MailView()
//}
