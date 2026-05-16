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
                    forecastingViewModel = ModelPredictViewModel(measurements: chartData)
                    do {
                        try forecastedData.append(forecastingViewModel!.forecast(minutes: 5))
                    } catch {
                        showAlert = true
                        alerText = "Сначала нажмте кнопку слева для получения данных"
                    }
                } label: {
                    Label("Generate forecast", systemImage: "play.fill")
                }
                .padding()
                .glassEffect()
//                .alert(isPresented: $showAlert){
//                    Alert(title: Text("Нет данных для предсказания"), message: Text(alerText))
//                }
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
