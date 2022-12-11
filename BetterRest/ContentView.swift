//
//  ContentView.swift
//  BetterRest
//
//  Created by Andy Wu on 12/8/22.
//

import SwiftUI
import CoreML

// DateComponents let us read of write specific parts of a date rather than the whole thing
// If we wanted a date that represented 8am today,

//var components = DateComponents()
//components.hour = 8
//components.minute = 0
//let date = Calendar.current.date(from: components)

/// https://www.hackingwithswift.com/quick-start/swiftui/how-to-run-some-code-when-state-changes-using-onchange
extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 0
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        VStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp.onChange({newValue in calculateBedtime()}), displayedComponents: .hourAndMinute)
                        
                }
                
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount.onChange({newValue in calculateBedtime()}), in: 4...12, step: 0.25)
                }
                
                Section("Daily coffee intake") {
                    Picker("Cups of coffee", selection: $coffeeAmount.onChange({newValue in calculateBedtime()})) {
                        Text("1 cup")
                        ForEach(2 ..< 20) {
                            Text("\($0) cups")
                        }
                    }
                }
            }
            
            VStack {
                Text("\(alertTitle.uppercased())")
                Text("\(alertMessage)")
                    .font(.system(size: 50))
            }
                
        }
    }
    
    func calculateBedtime() {
        // Core ML can throw errors in loading model and/or when we ask for predictions
        do {
            // Set up ML model
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            // Convert wakeTime to double for use in model prediction request
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            // Request prediction
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            // Convert predicted sleep time back to Date
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is "
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
