import Foundation

 protocol NetworkServiceProtocol {

     func getData(completion: @escaping (Result<DataModel?, Error>) -> Void)
     func getPlanetDescription(completion: @escaping (Result<PlanetModel?, Error>) -> Void)
//     func getResident(for stringURL: String, completion: @escaping (Result<ResidentModel?, Error>) -> Void)

 }

struct NetworkService: NetworkServiceProtocol {
    
    let urlNumber = "15"
    func getData(completion: @escaping (Result<DataModel?, Error>) -> Void) {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos/\(urlNumber)") else { return }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            
            if let data = data {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    let model = DataModel(
                        userId: jsonObject?["userId"] as! Int,
                        id: jsonObject?["userId"] as! Int,
                        title:jsonObject?["title"] as! String,
                        completed: jsonObject?["completed"] as! Bool
                    )
                    
                    completion(.success(model))
                } catch {
                    completion(.success(nil))
                }
            }
        }
        
        task.resume()
    }
    
         func getPlanetDescription(completion: @escaping (Result<PlanetModel?, Error>) -> Void) {
             guard let url = URL(string: "https://swapi.dev/api/planets/1") else { return }
    
             let session = URLSession.shared
             let task = session.dataTask(with: url) { data, response, error in
                 if let error = error {
                     completion(.failure(error))
                 }
    
                 if let data = data {
                     do {
                         let model = try JSONDecoder().decode(PlanetModel.self, from: data)
                         completion(.success(model))
                     } catch {
                         completion(.success(nil))
                     }
                 }
             }
    
             task.resume()
         }
    
    //     func getResident(for stringURL: String, completion: @escaping (Result<ResidentModel?, Error>) -> Void) {
    //         guard let url = URL(string: stringURL) else { return }
    //
    //         let session = URLSession.shared
    //         let task = session.dataTask(with: url) { data, response, error in
    //             if let error = error {
    //                 completion(.failure(error))
    //             }
    //
    //             if let data = data {
    //                 do {
    //                     let model = try JSONDecoder().decode(ResidentModel.self, from: data)
    //                     completion(.success(model))
    //                 } catch {
    //                     completion(.success(nil))
    //                 }
    //             }
    //         }
    //
    //         task.resume()
    //     }
    
    static func request(for stringURL: String) {
        guard let url = URL(string: stringURL) else { return }
        
        let session = URLSession.shared
        let task =  session.dataTask(with: url) { data, response, error in
            if let data = data, let string = String(data: data, encoding: .utf8) {
                print(string)
            }
            if let response = response as? HTTPURLResponse {
                print("Status Code: \(response.statusCode), Headers: \(response.allHeaderFields)")
            }
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        task.resume()
    }
}

