
import UIKit
import CoreData


class ViewController: UIViewController {
    
    //MARK: TableView DataSource
    private var organizations = [Organization]()
    private var fetchResultController : NSFetchedResultsController<Organization>?
    
    private var context : NSManagedObjectContext? {
        didSet {
            guard let context = context  else { return }
            self.setupFetchedResultController(for: context)
            self.fetchData()
            
        }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCellID")
        return tableView
    }()
    
   //MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        layout()
        setupNavigationBar()
    }
    
    //MARK: Methods
    
    func setContext(context : NSManagedObjectContext) {
        self.context = context
    }
    
    //MARK: Private methods
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
    }
    
    private func setupView() {
        self.view.backgroundColor = .blue
        view.addSubview(tableView)
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func setupRefresnControl() {
        tableView.refreshControl = UIRefreshControl()
    }
    
    private func setupFetchedResultController(for context : NSManagedObjectContext) {
        let request = Organization.fetchRequest()
        let sortDescription = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescription]
        self.fetchResultController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        self.fetchResultController?.delegate = self
    }
    
    private func fetchData() {
//        guard let context = self.context else { return }
//        let request = Organization.fetchRequest()
//        let sortDescription = NSSortDescriptor(key: "name", ascending: true)
//        request.sortDescriptors = [sortDescription]
        
        do {
            try self.fetchResultController?.performFetch()
//            self.organizations = try context.fetch(request)
            self.tableView.reloadData()
        } catch {
            fatalError("Cant fetch data from DB")
        }
    }
    
    //MARK: Objc Method
    
    @objc private func didTapAddButton() {
        guard let context = self.context else { return }
        let organization = Organization(context: context)
        organization.name = "Sber"
        
        do {
            try context.save()
        } catch {
            fatalError("Failed to save context in DB")
        }
    }
}

//MARK: TableView DataSource

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return organizations.count
        guard let sections = self.fetchResultController?.sections else { return 0 }
        
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "DefaultCellID")
//        let organization = self.organizations[indexPath.row]
        guard let organization = self.fetchResultController?.object(at: indexPath) else {return cell}
        var content = cell.defaultContentConfiguration()
            content.text = organization.name
            content.secondaryText = "Employees : \(organization.employees?.count ?? 0)"
        cell.contentConfiguration = content
        return cell
    }
}

//MARK: UITableViewDelegate

extension ViewController : UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let context = self.context else {return}
        guard let organization = self.fetchResultController?.object(at: indexPath) else {return}
        if editingStyle == .delete {
            do {
                context.delete(organization)
            try context.save()
                print("Delete cell by \(organization.name)")
//
            } catch {
                fatalError("Cant deleted cell in tableView")
            }
        }
    }
}

//MARK: FetchedResultController

extension ViewController : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
       
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            self.tableView.insertRows(at: [newIndexPath], with: .right)
        case .delete:
            guard let indexPath = indexPath else { return }
            self.tableView.deleteRows(at: [indexPath], with: .left)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            self.tableView.deleteRows(at: [indexPath], with: .left)
            self.tableView.insertRows(at: [newIndexPath], with: .right)
        case .update:
            guard let indexPath = indexPath else { return }
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        @unknown default :
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
}
