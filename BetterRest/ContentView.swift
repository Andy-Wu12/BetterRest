//
//  ContentView.swift
//  BetterRest
//
//  Created by Andy Wu on 12/8/22.
//

import SwiftUI

// DateComponents let us read of write specific parts of a date rather than the whole thing
// If we wanted a date that represented 8am today,

//var components = DateComponents()
//components.hour = 8
//components.minute = 0
//let date = Calendar.current.date(from: components)

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = Date.now
    
    var body: some View {
        VStack {
            Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
            DatePicker("Please enter a date", selection: $wakeUp, in: Date.now...)
                .labelsHidden()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
