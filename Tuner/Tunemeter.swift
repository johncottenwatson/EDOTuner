//
//  Tunemeter.swift
//  Tuner
//
//  Created by John Watson on 11/14/20.
//

import SwiftUI

struct SizeKey: PreferenceKey {
    static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        value = value ?? nextValue()
    }
}

struct Tunemeter: View {

    @State var width: CGFloat = 0
    @State var height: CGFloat = 0
    @State var xOffset: CGFloat = 0
    @State var yOffset: CGFloat = 0
    
    @Binding var frequency: Float
    @Binding var temperament: Float
    @Binding var rootFrequency: Float
    
    var nearestNote: Note {
        return Note(temperament: self.temperament, rootFrequency: self.rootFrequency, frequency: self.frequency)
    }
    
    var error: Float {
        let interval = frequency / nearestNote.frequency
        let halfSemitoneRatio = pow(2, 1 / (temperament * 2))
        return log(interval) / log(halfSemitoneRatio)
    }
    
    var noteLabels: [String] {
        let center = Note(temperament: self.temperament, rootFrequency: self.rootFrequency, frequency: self.frequency)
        let farLeft = center.getRelatedNote(stepsAway: -2)
        let left = center.getRelatedNote(stepsAway: -1)
        let right = center.getRelatedNote(stepsAway: 1)
        let farRight = center.getRelatedNote(stepsAway: 2)
        
        return [farLeft.description, left.description, center.description, right.description, farRight.description]
    }
    
    var centerBarWidth : CGFloat {
        return CGFloat(6 + 32 * pow(1 - abs(error), 10))
    }
    
    var body: some View {
        ZStack() {
            colorLerp(color1: ColorPalette.green, color2: ColorPalette.orange, amount: pow(abs(error), 0.5))
            
            Path { path in
                path.move(to: CGPoint(x: self.width / 2.0, y: 0))
                path.addLine(to: CGPoint(x: self.width / 2.0, y: self.height))
            }.stroke(lineWidth: centerBarWidth)
            .foregroundColor(ColorPalette.lightGray)
            .opacity(0.2)
            
            Text("\(noteLabels[0])")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(ColorPalette.lightGray)
                .offset(x: -2 * self.width / 3.0 - CGFloat(error) * self.width / 6.0)
            Text("\(noteLabels[1])")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(ColorPalette.lightGray)
                .offset(x: -1 * self.width / 3.0 - CGFloat(error) * self.width / 6.0)
            Text("\(noteLabels[2])")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(ColorPalette.lightGray)
                .offset(x: 0 * self.width / 3.0 - CGFloat(error) * self.width / 6.0)
            Text("\(noteLabels[3])")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(ColorPalette.lightGray)
                .offset(x: 1 * self.width / 3.0 - CGFloat(error) * self.width / 6.0)
            Text("\(noteLabels[4])")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(ColorPalette.lightGray)
                .offset(x: 2 * self.width / 3.0 - CGFloat(error) * self.width / 6.0)

        }.background(GeometryReader { proxy in
            Color.clear.preference(key: SizeKey.self, value: proxy.size)
        }).onPreferenceChange(SizeKey.self) { size in
            self.width = size?.width ?? 0.0
            self.height = size?.height ?? 0.0
            xOffset = self.width / 2.0
            yOffset = self.height / 2.0
        }
    }
}

struct Tunemeter_Previews: PreviewProvider {
    static var previews: some View {
        Tunemeter(frequency: .constant(450.0), temperament: .constant(7), rootFrequency: .constant(300))
    }
}

struct Note {
    var temperament: Float
    var rootFrequency: Float
    
    var octave: Int
    var noteNumber: Int
    
    var frequency: Float
    
    init(temperament: Float, rootFrequency: Float, frequency: Float) {
        self.temperament = temperament
        self.rootFrequency = rootFrequency
        
        octave = Int(floor(log2f(frequency / rootFrequency)))
        let reducedFrequency = frequency / pow(2, Float(octave))
        let interval = reducedFrequency / rootFrequency
        let semitoneRatio = pow(2, 1 / temperament)
        noteNumber = Int(round(log(interval) / log(semitoneRatio)))
        
        if noteNumber == Int(temperament) {
            octave += 1
            noteNumber = 0
        }
        
        self.frequency = rootFrequency * pow(2, Float(octave)) * pow(semitoneRatio, Float(noteNumber))
    }
    
    public func getRelatedNote(stepsAway: Int) -> Note {
        let semitoneRatio = pow(2, 1 / temperament)
        let relatedFrequency = frequency * pow(semitoneRatio, Float(stepsAway))
        
        return Note(temperament: self.temperament, rootFrequency: self.rootFrequency, frequency: relatedFrequency)
    }
    
    public var description: String {
        let subScriptCode = 0x2080 + (octave + 4)
        let subScript = Unicode.Scalar(subScriptCode)
        return "\(noteNumber + 1)\(subScript ?? "₀")"
    }
}
