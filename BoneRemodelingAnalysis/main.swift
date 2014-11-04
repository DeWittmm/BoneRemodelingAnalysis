//
//  main.swift
//  BoneFatigueAnalysis
//
//  Created by Michael DeWitt on 10/28/14.
//  Copyright (c) 2014 Michael DeWitt. All rights reserved.
//

import Foundation

//Input
var inputForce = cmdInput(1)!

var daysToSimulate = cmdInput(2)!
daysToSimulate += 94

var secondForce = cmdInput(3)!
var daysToSimulate2 = cmdInput(4)!

var postMenoPause: Bool = cmdInput(5)? > 0 ? true : false
var bisphosphonateTreatment: Bool = cmdInput(6) > 0 ? true : false

typealias Calc = (Void->Void)?

//Declarations
var k_c = 9.4E-11
var Q_R = 0.00113

var f_adisuse = 0.0
var phiZero = 1.875E-10
var potency = 0.0

var damage = [Double](count: 95, repeatedValue: INITIAL_DAMAGE)
var f_atotal = [Double](count: 95, repeatedValue: INITIAL_ACTIVATION_FREQUENCY)
var N_R = [Double](count: 95, repeatedValue: INITIAL_DENSITY_OF_RESORBING_BMUS)
var N_F = [Double](count: 95, repeatedValue: INITIAL_DENSITY_OF_FORMING_BMUS)
var porosity = [Double](count: 95, repeatedValue: INITIAL_POROSITY)
var density = [Double](count: 95, repeatedValue: INITIAL_BONE_DENSITY) //g/cm^3

let sigma = Double(inputForce)/CROSS_SECTIONAL_AREA

// MARK: Model

func modelDisuse(timePeriod: Range<Int>,supressionRate: Double? = nil, menopauseCalc: Calc = nil) {
    
    for i in timePeriod {
        
        var E = modulusOfElastisity(porosity: porosity[i-1])
        var epi = sigma/E
        
        var phi = NUM_CYCLES_OF_LOADING * pow(epi, 4)
        
        //Menopause Lab
        menopauseCalc?()
        
        var Q_F: Double
        if phi < phiZero {
            f_adisuse = f_aMax / (1.0 + exp(k_b * (phi - k_c)))
            Q_F = 0.000423 * (0.5 + 0.5 * phi / phiZero)
        } else {
            f_adisuse = 0
            Q_F = Q_Fo
        }
        
        let D_Formed = k_d * NUM_CYCLES_OF_LOADING * pow(epi, 4)
        let D_Removed = damage[i-1] * f_atotal[i-1] * AREA_OF_BMU * Fs
        damage.insert(damage[i-1] + (D_Formed - D_Removed), atIndex: i)
        
        let f_a0 = INITIAL_ACTIVATION_FREQUENCY
        let d_0 = INITIAL_DAMAGE
        var f_adamage = (f_aMax * f_a0) / (f_a0 + (f_aMax - f_a0) * exp(k_r * f_aMax*((damage[i] - d_0)/d_0)))
        
        f_atotal.insert(f_adamage + f_adisuse, atIndex: i)
        
        //Bisphosphonate Treatment Lab
        if (i > 2190 && supressionRate != nil) { //> 4 years
                potency = PotencyMax * (1 - exp(-supressionRate! * N_R[i-1]))
                f_atotal[i] *= (1 - potency)
                Q_R = 0.00113/1.3 //Ratio of formation to resorption
        }

        N_R.insert(sum(f_atotal, (i-24)...i), atIndex: i)
        N_F.insert(sum(f_atotal, (i-93)...(i-30)), atIndex: i)
        
        porosity.insert(porosity[i-1] + (Q_R * N_R[i] - Q_F * N_F[i]), atIndex: i)
        density.insert(2 * (1 - porosity[i]), atIndex: i)
    }
}

//MARK: Run

modelDisuse(95...daysToSimulate)
let firstDays = daysToSimulate
println("Days \(firstDays):(density: \(density[firstDays - 1]), damage: \(damage[firstDays - 1]) )")

func menoPauseSimulation(Void)->Void {
    phiZero += 5.63E-14 //looking for 11% decrease in density
    k_c = phiZero/2
}

let days = daysToSimulate2 + daysToSimulate
switch (postMenoPause, bisphosphonateTreatment) {
    case (false, false):
        modelDisuse(daysToSimulate...daysToSimulate2) //5 years
    case (true, false):
        modelDisuse(daysToSimulate..<days, supressionRate: nil, menoPauseSimulation)
    case (true, true):
        modelDisuse(daysToSimulate..<days, supressionRate: SuppressionRate, menoPauseSimulation)
    case (_, _):
        abort() // Cannot treat with bisphosphonate without Menopause
    break;
}

let keyPair = "PMax: \(PotencyMax), SupRate: \(SuppressionRate)"
writeValueAsCSV(formattedDescription(density), toFilePath: "Density-Days[\(keyPair)]")
writeValueAsCSV(formattedDescription(damage), toFilePath: "Damage-Days[\(keyPair)]")

println(keyPair)
println("Days \(days):(density: \(density[days - 1]), damage: \(damage[days - 1]) )")
println("Potency: \(potency)")
println("Final phi: \(phiZero)") //2.89