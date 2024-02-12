//
//  Alien.swift
//  SpaceGameSKPractice
//
//  Created by Quinn Wienke on 2/11/24.
//

import GameplayKit
struct Alien {
    var alienType: String
    var health: Int
    var image: String
    
    init(alienType: String, health: Int, image: String) {
        self.alienType = alienType
        self.health = health
        self.image = image
    }
}

class AlienClass {
    var possibleAliens = [
        Alien(alienType: "alien1", health: 50, image: "alien1"),
        Alien(alienType: "alien2", health: 100, image: "alien2")
    ]

    func shuffleAliens() {
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [Alien]
    }

    func useSelectedAlien() -> Alien {
        let selectedAlien = possibleAliens[0]

            return selectedAlien
    }
}





