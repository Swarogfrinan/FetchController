import Foundation

//First question
struct DataModel {

     let userId: Int
     let id: Int
     let title: String
     let completed: Bool

 }

//Second question
 struct PlanetModel: Decodable {

     let name: String
     let rotationPeriod: String
     let orbitalPeriod: String
     let diameter: String
     let climate: String
     let gravity: String
     let terrain: String
     let surfaceWater: String
     let population: String
     let residents: [String]
     let films: [String]
     let created: String
     let edited: String
     let url: String

     enum CodingKeys: String, CodingKey {
         case name, diameter, climate, gravity, terrain
         case population, residents, films, created, edited, url
         case rotationPeriod = "rotation_period"
         case orbitalPeriod = "orbital_period"
         case surfaceWater = "surface_water"
     }

 }

struct ResidentModel: Decodable {
    
    let name: String
}
