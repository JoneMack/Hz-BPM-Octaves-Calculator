//
//  Calculations.swift
//  Octaves
//
//  Created by 262Hz on 12/9/15.
//  Copyright © 2015 262Hz. All rights reserved.
//

import Foundation

let secondsInOneMinute = 60.0

let centsInOneOctave = 1200.0

let aAboveMiddleC = 440.0
let aBelowMiddleC = aAboveMiddleC/2

// fastestHz determines preferred range for frequency.
let fastestHz = 500.0
let slowestHz = fastestHz/2

// fastestBPM determines preferred range for tempo.
let fastestBPM = 150.0
let slowestBPM = fastestBPM/2

/**
 
 Returns a multiplier value for a given number of half steps.
 
 */
func halfSteps(number: Int) -> Double {
    return pow(2, Double(number)/12)
}

/**
 
 Returns a Hz "octave equivalent" in the preferred range for a given frequency.
 
 */
func hzInPreferredRange(var hz: Double) -> Double {
    if hz <= 0 {
        return 0 // if Hz is zero or negative, no sense in proceeding with calculations.
    }
    
    while hz > fastestHz {
        hz = hz/2
    }
    
    while hz < slowestHz {
        hz = hz*2
    }
    
    return hz
}

/**
 
 Returns a BPM "octave equivalent" in the preferred range for a given BPM.
 
 */
func bpmInPreferredRange(var bpm: Double) -> Double {
    if bpm <= 0 {
        return 0 // if BPM is zero or negative, no sense in proceeding with calculations.
    }
    
    while bpm > fastestBPM {
        bpm = bpm/2
    }
    
    while bpm < slowestBPM {
        bpm = bpm*2
    }
    
    return bpm
}

/**
 
 Returns a BPM value in the preferred range which is "in tune" with the given frequency.
 
 */
func hzToBPM(hz: Double) -> Double {
    let bpm = hz*secondsInOneMinute
    
    return bpmInPreferredRange(bpm)
}

/**
 
 Returns a Hz value in the preferred range which is "in tune" with the given BPM.
 
 */
func bpmToHz(bpm: Double) -> Double {
    let hz = bpm/secondsInOneMinute
    
    return hzInPreferredRange(hz)
}

/**
 
 Finds the closest musical note for a given frequency.
 
 */
func hzToNoteNameAndCentsOffset(var hz: Double) -> (noteName: String, centsOffset: Double) {
    
    if hz <= 0 {
        return ("", 0) // If Hz is zero or negative, no sense in proceeding with calculations.
    }
    
    var noteName = ""
    var centsOffset = 0.0
    let defaultNoteNames = ["A", "B♭", "B", "C", "C♯", "D", "E♭", "E", "F", "F♯", "G", "G♯", "A"]
    
    // Convert Hz to "octave equivalent" in range between aBelowMiddleC and aAboveMiddleC so that calculations are easy.
    
    while hz > aAboveMiddleC {
        hz = hz/2
    }
    
    while hz < aBelowMiddleC {
        hz = hz*2
    }
    
    // Create Hz values for reference notes using equal temperament math.
    
    let a = aBelowMiddleC
    let bFlat = a * halfSteps(1)
    let b = a * halfSteps(2)
    let c = a * halfSteps(3)
    let cSharp = a * halfSteps(4)
    let d = a * halfSteps(5)
    let eFlat = a * halfSteps(6)
    let e = a * halfSteps(7)
    let f = a * halfSteps(8)
    let fSharp = a * halfSteps(9)
    let g = a * halfSteps(10)
    let gSharp = a * halfSteps(11)
    let a2 = aAboveMiddleC
    
    let referenceNotes = [a, bFlat, b, c, cSharp, d, eFlat, e, f, fSharp, g, gSharp, a2]
    var positiveDistanceRatioToClosestNote = 2.0 // Note: initial value is set to the highest possible ratio.
    var closestNoteIndex = -1
    var offsetIsNegative = false
    var index = 0
    
    // Determine closest note, and find distance in terms of frequency ratio.
    
    for note in referenceNotes {
        
        var higherNumber: Double = 0
        var lowerNumber: Double = 0
        var negative = false
        
        if note >= hz {
            higherNumber = note
            lowerNumber = hz
            negative = true
        } else {
            higherNumber = hz
            lowerNumber = note
            negative = false
        }
        
        let positiveDistanceRatio = higherNumber/lowerNumber
        
        if positiveDistanceRatio < positiveDistanceRatioToClosestNote {
            positiveDistanceRatioToClosestNote = positiveDistanceRatio
            closestNoteIndex = index
            offsetIsNegative = negative
        }
        
        index++
    }
    
    noteName = defaultNoteNames[closestNoteIndex]
    
    centsOffset = centsInOneOctave * log2(positiveDistanceRatioToClosestNote) // Convert frequency ratio distance to musical "cents".
    
    if offsetIsNegative {
        centsOffset *= -1
    }
    
    return (noteName, centsOffset)
}

/**
 
 Returns a Hz value in the preferred range for given note name and cents offset.
 
 */
func noteNameAndCentsOffsetToHz(noteName: String, centsOffset: Double) -> Double {
    var hz = aBelowMiddleC
    
    // Calculate Hz value for note using equal temperament math.
    
    switch noteName {
    case "A":
        hz *= 1
    case "A♯", "B♭":
        hz *= halfSteps(1)
    case "B":
        hz *= halfSteps(2)
    case "C":
        hz *= halfSteps(3)
    case "C♯", "D♭":
        hz *= halfSteps(4)
    case "D":
        hz *= halfSteps(5)
    case "D♯", "E♭":
        hz *= halfSteps(6)
    case "E":
        hz *= halfSteps(7)
    case "F":
        hz *= halfSteps(8)
    case "F♯", "G♭":
        hz *= halfSteps(9)
    case "G":
        hz *= halfSteps(10)
    case "G♯", "A♭":
        hz *= halfSteps(11)
    default:
        preconditionFailure("Unknown note name: \(noteName)")
    }
    
    hz *= pow(2, centsOffset/centsInOneOctave) // Modify Hz value based on centsOffset argument.
    
    hz = hzInPreferredRange(hz)
    
    return hz
}