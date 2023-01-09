import UIKit

class InfoViewController: UIViewController {
    
    //MARK: UI
    
    private lazy var tableView : UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var dataLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private lazy var titleLabel = makeLabel()
    private lazy var idLabel = makeLabel()
    
    //MARK: Variables
    
    private var service : NetworkServiceProtocol
    private let group = DispatchGroup()
    private var links = [String]()
    private var residents = [String]()
    
   
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
//        tableView.delegate = self
//        tableView.dataSource = self
        setupLayout()
//        getData()
        group.enter()
                getPlanetDescription()
        group.wait()
        //        getResident(for: links)
        tableView.reloadData()
    }
    
 
    
 

//MARK: - Initialization

init(service: NetworkServiceProtocol) {
    self.service = service
    super.init(nibName: nil, bundle: nil)
}

required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
}
}
    

//MARK: - Private functions

private extension InfoViewController {
    
    func setupView() {
        view.backgroundColor = .systemBlue
        title = "Info"
    }
    
    func setupLayout() {
        [dataLabel, titleLabel, idLabel, tableView].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            dataLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dataLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            dataLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: dataLabel.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            idLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor,constant: 16),
            idLabel.leadingAnchor.constraint(equalTo: dataLabel.leadingAnchor),
            
        ])
    }
    
    func getData() {
        service.getData { [weak self] result in
            switch result {
            case .success(let data):
                guard let data = data else { return }
                
                DispatchQueue.main.async {
                    self?.dataLabel.text = data.title
                    self?.titleLabel.text = String(data.userId)
                    self?.idLabel.text = data.title
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getPlanetDescription() {
        service.getPlanetDescription { [weak self] result in
            switch result {
            case .success(let model):
                guard let model = model else { return }

                self?.links.append(contentsOf: model.residents)
                DispatchQueue.main.async {
                    self?.dataLabel.text = "Planet Tatuin period: \(model.orbitalPeriod)"
                    self?.titleLabel.text = "Name of the planet\(model.name)"
                    self?.idLabel.text = "population on planet \(model.population)"
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            self?.group.leave()
        }
    }
//
//    func getResident(for links: [String]) {
//        links.forEach { link in
//            self.service.getResident(for: link) { [weak self] result in
//                switch result {
//                case .success(let success):
//                    guard let person = success else { return }
//
//                    self?.residents.append(person.name)
//
//                    DispatchQueue.main.async {
//                        self?.tableView.reloadData()
//                    }
//                case .failure(let failure):
//                    print(failure.localizedDescription)
//                }
//            }
//        }
//    }
    
    func makeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    
}


//MARK: - UITableViewDelegate

 extension InfoViewController: UITableViewDelegate {
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         print(indexPath.row)
     }
 }

 //MARK: - UITableViewDataSource

extension InfoViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        residents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content: UIListContentConfiguration = cell.defaultContentConfiguration()
        
        content.text = residents[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
}

