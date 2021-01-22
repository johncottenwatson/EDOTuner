//
//  TunerApp.swift
//  Tuner
//
//  Created by John Watson on 11/13/20.
//

import SwiftUI

@main
struct TunerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ColorPalette {
    static let lightGray = Color(red: 247 / 255, green: 244 / 255, blue: 236 / 255)
    static let darkGray = Color(red: 128 / 255, green: 125 / 255, blue: 119 / 255)
    static let orange = Color(red: 241 / 255, green: 164 / 255, blue: 125 / 255)
    //static let blue = Color(red: 182 / 255, green: 235 / 255, blue: 241 / 255)
    static let blue = Color(red: 112 / 255, green: 155 / 255, blue: 231 / 255)
    //static let green = Color(red: 203 / 255, green: 230 / 255, blue: 193 / 255)
    static let green = Color(red: 60 / 255, green: 200 / 255, blue: 70 / 255)
}

// Returns the color a given amount betweeen two given colors
func colorLerp(color1: Color, color2: Color, amount: Float) -> Color {

    let antiAmount = 1.0 - amount
    
    let c1 = color1.cgColor!.components
    let c2 = color2.cgColor!.components
    
    let r: Double = Double(Float(c1![0]) * antiAmount + Float(c2![0]) * amount)
    let g: Double = Double(Float(c1![1]) * antiAmount + Float(c2![1]) * amount)
    let b: Double = Double(Float(c1![2]) * antiAmount + Float(c2![2]) * amount)
    
    return Color(red: r, green: g, blue: b)
}
