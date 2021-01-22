//
//  Note.swift
//  Tuner
//
//  Created by John Watson on 1/20/21.
//

import Foundation

// Struct containing information for a given note
// as defined by temperament, root frequency, octave, and note number
public struct Note {
    // EDO scheme this note belongs to
    var temperament: Float
    
    // Frequency which the EDO scheme is build on
    var rootFrequency: Float
    
    // Octave of the note
    var octave: Int
    // Note number (out of temperament number), 0 = root pitch class
    var noteNumber: Int
    
    // Frequency of this note (derived from other fields, but not computed property for performance)
    var frequency: Float
    
    // Nearest note init: Note is initialized as nearest note to given frequency in given scheme
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
    
    // Returns the note a certain number of steps away from this note under the same scheme
    public func getRelatedNote(stepsAway: Int) -> Note {
        let semitoneRatio = pow(2, 1 / temperament)
        let relatedFrequency = frequency * pow(semitoneRatio, Float(stepsAway))
        
        return Note(temperament: self.temperament, rootFrequency: self.rootFrequency, frequency: relatedFrequency)
    }
    
    // The number text name for this note
    public var numberDescription: String {
        let subScriptCode = 0x2080 + (octave + 4)
        let subScript = Unicode.Scalar(subScriptCode)
        return "\(noteNumber)\(subScript ?? "₀")"
    }
    
    // The letter text name for this note
    public var letterDescription: String {
        let subScriptCode = 0x2080 + (octave + 4)
        let subScript = Unicode.Scalar(subScriptCode)
        let letterName = Note.getLetterNames(temperament: Int(temperament))[noteNumber]
        return "\(letterName)\(subScript ?? "₀")"
    }
    
    // 41edo ups and downs notation hard coded for use with Kite Guitar
    static let kiteGuitarLetterNames = ["C", "^C", "^^C", "vC#", "C#", "^C#", "vD",
                                        "D", "^D", "^^D", "vD#", "D#", "^D#", "vE",
                                        "E", "^E", "^^E",
                                        "F", "^F", "^^F", "vF#", "F#", "^F#", "vG",
                                        "G", "^G", "^^G", "vG#", "G#", "^G#", "vA",
                                        "A", "^A", "^^A", "vA#", "A#", "^A#", "vB",
                                        "B", "^B", "^^B"]
    
    // Returns the list of pitch class letter names for a given temperament
    // NOTE: uses custom reduced circle of fifths notation where naturals
    // are filled in in C->G direction, then F is added. Accidentals are
    // notated as cumulative sharps of the nearest lower natural
    // e.g. C C# C#2 C#3 D
    public static func getLetterNames(temperament: Int) -> [String] {
        
        // Use ups and downs notation with 41edo for ease of use with Kite Guitar
        if temperament == 41 {
            return Note.kiteGuitarLetterNames
        }
        
        var letterNames: [String] = Array(repeating: "", count: temperament)
        
        let fifthsArc = ["C", "G", "D", "A", "E", "B"]
        let fifthStep = Int(round(Double(temperament) * log2(1.5)))
        
        // Fill in fifths arc in C->G direction
        var index = 0
        for letter in fifthsArc {
            if letterNames[index] == "" {
                letterNames[index] = letter
            }
            index = (index + fifthStep) % temperament
        }
        
        // Add fourth (F)
        let fourthIndex = temperament - fifthStep
        if letterNames[fourthIndex] == "" {
            letterNames[fourthIndex] = "F"
        }
        
        // Fill in sharps
        var sharpCount = 0
        var lastLetter = "C"
        for index in 0 ..< letterNames.count {
            if letterNames[index] != "" {
                lastLetter = letterNames[index]
                sharpCount = 0
            } else {
                sharpCount += 1
                letterNames[index] = lastLetter + "#"
                if (sharpCount > 1) {
                    letterNames[index] += "\(sharpCount)"
                }
            }
        }
        
        return letterNames
    }
}
