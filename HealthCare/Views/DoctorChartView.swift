//
//  doctorChartView.swift
//  HealthCare
//
//  Created by lonely. on 5/9/26.
//

import SwiftUI
import Charts

struct DoctorChartView: View {
    @EnvironmentObject var user: AppUser
    @ObservedObject var doctor: DoctorViewModel
    @State var forecastingViewModel: ModelPredictViewModel?
    @State var date: Date = Date()
    @State var chartData: [RawMeasurement] = []
    @State var forecastedData: [RawMeasurement] = []
    @State var uid: String?
    @State var patients: [DoctorPatientDisplay] = []
    @State var showAlert: Bool = false
    @State var alerText: String = ""
    @EnvironmentObject var pickedPatient: PickedPatient
    
    
    var body: some View {
        VStack{
            DatePicker(selection: $date, displayedComponents: [.date]) {
                Label("Date", systemImage: "calendar")
            }
            .datePickerStyle(.automatic)
            
            HStack{
                Picker("text", selection: $uid) {
                    ForEach(patients) { pat in
                        Text(pat.fullName).tag(pat.uid)
                    }
                }
                .onChange(of: uid, { oldValue, newValue in
                    let newPat = patients.map{$0}.filter { patient in
                        if patient.uid == newValue {
                            return true
                        } else {
                            return false
                        }
                    }
                    pickedPatient.fullName = newPat[0].fullName
                    pickedPatient.uid = newPat[0].uid
                    pickedPatient.gender = newPat[0].gender
                    pickedPatient.birthday = newPat[0].birthday
                    pickedPatient.email = newPat[0].email
                    pickedPatient.phone = newPat[0].phone
                    pickedPatient.height = newPat[0].height
                    pickedPatient.weight = newPat[0].weight
                })
                .pickerStyle(.automatic)
                
                Button {
                    UIPasteboard.general.string = uid
                    showAlert = true
                    alerText = "ID пациента скопирован"
                } label: {
                    Label("Скопировать ID", systemImage: "document.on.document")
                }
                .buttonStyle(.glass)
                
            }
            
            Chart(forecastedData) {measure in
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
                        if let uid = uid{
                            do{
                                try await doctor.getTodayData(date: date, uid: uid)
                                chartData = doctor.patientsMeasurements
                                forecastedData = chartData
                            } catch {
                                showAlert = true
                                alerText = error.localizedDescription
                            }
                        } else {
                            showAlert = true
                            alerText = "Some error"
                        }
                    }
                    
                } label: {
                    Label("Get measurements", systemImage: "chart.line.uptrend.xyaxis")
                }
                .padding()
                .glassEffect()
                
                Button {
                    guard let uid = uid else {
                        showAlert = true
                        alerText = "Нет данных для предсказания"
                        return
                    }
                    forecastingViewModel = ModelPredictViewModel(userId: uid, measurements: chartData)
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
        .alert(isPresented: $showAlert){
            Alert(title: Text(alerText))
        }
        .task({
            if self.patients.isEmpty{
                self.patients = []
                do{
                    self.patients = try await doctor.loadPatients()
                    self.patients.sort { $0.fullName < $1.fullName }
                    if !self.patients.isEmpty{
                        self.uid = patients[0].uid
                    }
                } catch {
                    
                }
            }
        })
    }
}

//#Preview {
//    doctorChartView()
//}
