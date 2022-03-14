import Foundation
import UIKit

//scraped from https://www.swiftbysundell.com/posts/reusable-data-sources-in-swift
class VCSTableViewDataSource<Model, Cell>: NSObject, UITableViewDataSource {
    typealias VCSCellConfigurator = (Model, Cell) -> Void
    
    var models: [Model]
    
    internal let reuseIdentifier: String
    internal let cellConfigurator: VCSCellConfigurator
    
    init(models: [Model], reuseIdentifier: String, cellConfigurator: @escaping VCSCellConfigurator) {
        self.models = models
        self.reuseIdentifier = reuseIdentifier
        self.cellConfigurator = cellConfigurator
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if let typedCell = cell as? Cell {
            self.cellConfigurator(model, typedCell)
        } else {
            print("Warning cant cast UITableViewCell to cell type \(Cell.self), for reuseIdentifier: \(reuseIdentifier) and indexPath \(indexPath). Cell is not modified!")
        }
        
        return cell
    }
}
