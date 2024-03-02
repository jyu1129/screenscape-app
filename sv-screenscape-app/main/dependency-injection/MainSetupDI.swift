//
//  MainSetupDI.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 01/03/2024.
//

import Swinject

class MainSetupDI {
    static func setupDI(container: Container) {
        setupData(container: container)
        setupDomain(container: container)
        setupPresentation(container: container)
    }
    
    static func setupData(container: Container) {
    }
    
    static func setupDomain(container: Container) {
    }
    
    static func setupPresentation(container: Container) {
    }
}
