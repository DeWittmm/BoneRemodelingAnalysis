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

var daysToSimulate2 = cmdInput(3)!
var secondForce = cmdInput(4)!
var postMenoPause = cmdInput(5)

//Declarations
var k_c = 9.4E-11
var f_adisuse = 0.0
var phiZero = 1.875E-10

var damage = [Double](count: 95, repeatedValue: INITIAL_DAMAGE)
var f_atotal = [Double](count: 95, repeatedValue: f_a0)
var N_R = [Double](count: 95, repeatedValue: 0.1675)
var N_F = [Double](count: 95, repeatedValue: 0.4288)
var porosity = [Double](count: 95, repeatedValue: INITIAL_POROSITY)
var density = [Double](count: 95, repeatedValue: 1.90) //g/cm^3

let sigma = Double(inputForce)/CROSS_SECTIONAL_AREA

// MARK: Model
func modelDisuse(timePeriod: Range<Int>, extraComp: (Void->Void)? = nil) {
    for i in timePeriod {
        
        var E:Double
        if porosity[i-1] < 0.097 {
            E = 23400 * pow((1 - porosity[i-1]), 5.74)
        } else {
            E = 14927 * pow(1 - porosity[i-1], 1.33)
        }
        
        var epi = sigma/E
        var phi = NUM_CYCLES_OF_LOADING * pow(epi,4)
        
        extraComp?()
        
        var Q_F: Double
        if phi < phiZero {
            f_adisuse = f_aMax / (1.0 + exp(k_b * (phi - k_c)))
            Q_F = 0.000423 * (0.5 + 0.5 * phi / phiZero)
        }
        else {
            f_adisuse = 0
            Q_F = Q_Fo
        }
        
        let D_Formed = k_d * NUM_CYCLES_OF_LOADING * pow(epi, 4)
        let D_Removed = damage[i-1] * f_atotal[i-1] * AREA_OF_BMU * Fs
        damage.insert(damage[i-1] + (D_Formed - D_Removed), atIndex: i)
        
        var f_adamage = (f_aMax * f_a0) / (f_a0 + (f_aMax - f_a0) * exp(k_r * f_aMax*((damage[i] - INITIAL_DAMAGE)/INITIAL_DAMAGE)))
        
        f_atotal.append(f_adamage + f_adisuse)
        
        N_R.insert(sum(f_atotal, (i-24)...i), atIndex: i)
        N_F.insert(sum(f_atotal, (i-93)...(i-30)), atIndex: i)
        
        porosity.insert(porosity[i-1] + (Q_R*N_R[i] - Q_F*N_F[i]), atIndex: i)
        density.insert(2 * (1 - porosity[i]), atIndex: i)
    }
}

//MARK: Run

modelDisuse(95...daysToSimulate)
println("rho: \(density)")

if postMenoPause == 0 { //No simulation
    modelDisuse(daysToSimulate...daysToSimulate2) //5 years
} else {
    modelDisuse(daysToSimulate..<(daysToSimulate2 + daysToSimulate)) {
        phiZero += 5.63E-14 //looking for 11% decrease in density
        k_c = phiZero/2
    }
    
    
    //Final Rho 0.4627
    writeValueAsCSV(formattedDescription(density), toFilePath: "Density-Days[@\(inputForce)]")
    writeValueAsCSV(formattedDescription(damage), toFilePath: "Damage-Days[@\(inputForce)]")
    println("Final phi: \(phiZero)") //2.89
    println("\n\n\n\n")
    println("Dmg: \(damage)")
}