//
//  SearchRecipeVC.swift
//  RecipeMaster
//
//  Created by Sudhakar Dasari on 25/07/19.
//  Copyright © 2019 sudhakar. All rights reserved.
//

import UIKit

class RecipeCell: UITableViewCell {
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        recipeImage.applyCornerRadius(radius: 3.0)
    }
}

class SearchRecipeVC: UIViewController {

    lazy private var searchController = UISearchController()
    lazy private var responseArray = NSMutableArray()
    
    @IBOutlet private weak var listingTV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            navigationItem.searchController = controller
            navigationItem.hidesSearchBarWhenScrolling = false
            controller.searchBar.delegate = self
            
            return controller
        })()
    }

}
extension SearchRecipeVC : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        searchController.dismiss(animated: true)
        print("search text \(searchBar.text ?? "")")
    }
}
extension SearchRecipeVC:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell") as! RecipeCell
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.openSFSafariVC(WithURL: "http://www.google.com")
    }
    
}
