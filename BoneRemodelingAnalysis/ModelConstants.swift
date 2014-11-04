//
//  ModelConstants.swift
//  BoneFatigueAnalysis
//
//  Created by Michael DeWitt on 10/28/14.
//  Copyright (c) 2014 Michael DeWitt. All rights reserved.
//

// Background
//http://en.wikipedia.org/wiki/Bone_remodeling
// BMU - basic multicellular unit

import Foundation

let k_b = 6.5E10
let k_d = 1.85E5 //mm/mm^2
let NUM_CYCLES_OF_LOADING = 3000.0 //cycles of loading
let CROSS_SECTIONAL_AREA = 100.0 //Cross Sectional area

//Initial Values
let INITIAL_DAMAGE = 0.0366; //mm (crack length) / mm^2 (bone area)
let INITIAL_ACTIVATION_FREQUENCY = 0.00670
let INITIAL_POROSITY = 0.0500
let INITIAL_DENSITY_OF_FORMING_BMUS = 0.04288 //BMUs/mm^2
let INITIAL_DENSITY_OF_RESORBING_BMUS = 0.1675 //BMUs/mm^2
let INITIAL_BONE_DENSITY = 1.90 //g/cm^3

let AREA_OF_BMU = 0.02835 //Area of a BMU [mm^2]
let Q_Fo = 0.000423
let f_aMax = 0.5
let k_r = -1.6
let Fs = 5.0
let TIME_STEP = 1

//Vary between 0.7 - 1.0
let PotencyMax = 1.0 //0.7 //
let SuppressionRate = 20.0 //5.0