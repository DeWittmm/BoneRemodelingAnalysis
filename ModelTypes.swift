//
//  ModelTypes.swift
//  BoneRemodelingAnalysis
//
//  Created by Michael DeWitt on 11/4/14.
//  Copyright (c) 2014 Michael DeWitt. All rights reserved.
//

import Foundation

func modulusOfElastisity(#porosity: Double) -> Double {
    if porosity < 0.097 {
        return 23400 * pow(1 - porosity, 5.74)
    } else {
        return 14927 * pow(1 - porosity, 1.33)
    }
}