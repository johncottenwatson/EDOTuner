//
//  TunerView.swift
//  Tuner
//
//  Created by John Watson on 11/15/20.
//

import SwiftUI
import AudioKit

struct TunerView: View {
    
    @ObservedObject var tuner: Tuner
    
    @State var temperament: Float = 12.0
    @State var rootFrequency: Float = 262.0
    
    var centsOff: Int {
        let nearestNote = Note(temperament: self.temperament, rootFrequency: self.rootFrequency, frequency: tuner.dampedFrequency)
        let interval = tuner.dampedFrequency / nearestNote.frequency
        return Int(round(1200.0 * log2(interval)))
    }
    
    var body: some View {
        ZStack() {
            // Background
            ColorPalette.lightGray
                .ignoresSafeArea()
            // Content
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("edo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(ColorPalette.blue)
                        .padding(.bottom, 40)
                        .padding(.top, -20)
                    // Temperament group
                    HStack() {
                        Text("Number of Notes:")
                            .font(.title2)
                            .foregroundColor(ColorPalette.darkGray)
                        Text("\(Int(temperament))")
                            .font(.title2)
                            .foregroundColor(ColorPalette.blue)
                    }
                    HStack() {
                        Button(action: {
                            temperament = max(1, temperament - 1)
                        }) {
                            Text("1")
                                .font(.body)
                                .foregroundColor(ColorPalette.darkGray)
                        }
                        Slider(value: $temperament,
                               in: 1...31,
                               step: 1)
                            .accentColor(ColorPalette.blue)
                            .foregroundColor(ColorPalette.blue)
                        Button(action: {
                            temperament += 1
                        }) {
                            Text("31")
                                .font(.body)
                                .foregroundColor(ColorPalette.darkGray)
                        }
                    }
                    // Root frequency group
                    HStack() {
                        Text("Root Frequency:")
                            .font(.title2)
                            .foregroundColor(ColorPalette.darkGray)
                        Text("\(Int(rootFrequency))\(rootFrequency == 262 ? " (Middle C)" : "")")
                            .font(.title2)
                            .foregroundColor(ColorPalette.blue)
                    }
                    HStack() {
                        Button(action: {
                            rootFrequency = max(262, rootFrequency - 1)
                        }) {
                            Text("C₄")
                                .font(.body)
                                .foregroundColor(ColorPalette.darkGray)
                        }
                        Slider(value: $rootFrequency,
                               in: 262...523,
                               step: 1)
                            .accentColor(ColorPalette.blue)
                            .foregroundColor(ColorPalette.blue)
                        Button(action: {
                            rootFrequency = min(523, rootFrequency - 1)
                        }) {
                            Text("C₅ - 1")
                                .font(.body)
                                .foregroundColor(ColorPalette.darkGray)
                        }
                    }
                }.padding(20)
                Spacer()
                Tunemeter(frequency: $tuner.dampedFrequency, temperament: self.$temperament, rootFrequency: self.$rootFrequency)
                    .frame(width: UIScreen.main.bounds.size.width)
                VStack(alignment: .leading) {
                    // Temperament group
                    HStack() {
                        Text("Frequency:")
                            .font(.title2)
                            .foregroundColor(ColorPalette.darkGray)
                        Text("\(Int(tuner.frequency)) Hz")
                            .font(.title2)
                            .foregroundColor(ColorPalette.blue)
                    }.padding(.bottom, 5)
                    HStack() {
                        Text("Error:")
                            .font(.title2)
                            .foregroundColor(ColorPalette.darkGray)
                        Text(String(format: "\(centsOff >= 0 ? "+" : "-") \(abs(centsOff)) cents"))
                            .font(.title2)
                            .foregroundColor(ColorPalette.blue)
                    }
                }
                .padding(20)
                Spacer()
            }.padding(.vertical, 10)
        }.onAppear() {
            tuner.start()
        }.onDisappear() {
            tuner.stop()
        }
    }
}

struct TunerView_Previews: PreviewProvider {
    static var previews: some View {
        TunerView(tuner: Tuner())
    }
}

