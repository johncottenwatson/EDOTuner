//
//  TunerView.swift
//  Tuner
//
//  Created by John Watson on 11/15/20.
//

import SwiftUI
import AudioKit

// The main view of EDOTuner containing parameter interactables and tunemeter
struct TunerView: View {
    
    let minTemperament: Float = 1
    let maxTemperament: Float = 41
    
    @ObservedObject var tuner: Tuner
    
    @State var temperament: Float = 12.0
    @State var rootFrequency: Float = 262.0
    @State var displayLetters: Bool = true
    
    // Current frequency objective (12edo) cents off from nearest ntoe
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
                    Picker("", selection: $displayLetters) {
                        Text("Letter Names").tag(true)
                        Text("Number Names").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom, 20)
                    .padding(.top, 0)
                    .onAppear() {
                        UISegmentedControl.appearance().setTitleTextAttributes([.font : UIFont.preferredFont(forTextStyle: .body)], for: .normal)
                        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor : UIColor(ColorPalette.darkGray)], for: .normal)
                        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor : UIColor(ColorPalette.darkGray)], for: .selected)
                    }
                        
                    temperamentGroup
                    rootFrequencyGroup
                }.padding(20)
                Spacer()
                Tunemeter(displayLetters: $displayLetters, frequency: $tuner.dampedFrequency, temperament: self.$temperament, rootFrequency: self.$rootFrequency)
                    .frame(width: UIScreen.main.bounds.size.width)
                    realTimeDataGroup
                .padding(20)
                Spacer()
            }.padding(.vertical, 10)
        }.onAppear() {
            tuner.start()
        }.onDisappear() {
            tuner.stop()
        }
    }
    
    // Group for changing temperament
    var temperamentGroup: some View {
        Group {
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
                    temperament = max(minTemperament, temperament - 1)
                }) {
                    Text("\(Int(minTemperament))")
                        .font(.body)
                        .foregroundColor(ColorPalette.darkGray)
                }
                Slider(value: $temperament,
                       in: minTemperament ... maxTemperament,
                       step: 1)
                    .accentColor(ColorPalette.blue)
                    .foregroundColor(ColorPalette.blue)
                Button(action: {
                    temperament = min(maxTemperament, temperament + 1)
                }) {
                    Text("\(Int(maxTemperament))")
                        .font(.body)
                        .foregroundColor(ColorPalette.darkGray)
                }
            }
        }
    }
    
    // Group for changing root frequency
    var rootFrequencyGroup: some View {
        Group {
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
                    rootFrequency = min(523, rootFrequency + 1)
                }) {
                    Text("C₅ - 1")
                        .font(.body)
                        .foregroundColor(ColorPalette.darkGray)
                }
            }
        }
    }
    
    // Group for displaying real time data (frequency and error from nearest note)
    var realTimeDataGroup: some View {
        VStack(alignment: .leading) {
            HStack() {
                Text("Frequency:")
                    .font(.title2)
                    .foregroundColor(ColorPalette.darkGray)
                Text("\(Int(tuner.dampedFrequency)) Hz")
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
    }
}

struct TunerView_Previews: PreviewProvider {
    static var previews: some View {
        TunerView(tuner: Tuner())
    }
}

