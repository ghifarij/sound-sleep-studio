//
//  ContentView.swift
//  SleepWatch Watch App
//
//  Created by Wentao Guo on 28/05/25.
//

import SwiftUI



struct ContentView: View {
    @StateObject private var hrManager = HeartRateManager()

    var body: some View {
        VStack {
            Text("❤️ BPM")
                .font(.headline)
            Text("\(Int(hrManager.bpm))")
                .font(.system(size: 50))
                .foregroundColor(.red)

            HStack {
                Button("Start") {
                    hrManager.startStreaming()
                }
                Button("Stop") {
                    hrManager.stopStreaming()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
