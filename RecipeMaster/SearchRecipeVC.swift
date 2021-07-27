//
//  SearchRecipeVC.swift
//  RecipeMaster
//
//  Created by Sudhakar Dasari on 25/07/19.
//  Copyright © 2019 sudhakar. All rights reserved.
//

import UIKit
import AlamofireImage

class RecipeCell: UITableViewCell {
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var imageBV: UIView!
    @IBOutlet weak var shareButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        recipeImage.applyCornerRadius(radius: 15.0)
        imageBV.applyCornerRadius(radius: 15.0)
        imageBV.showShadow(withRadius:5.0)
    }
}

class SearchRecipeVC: UIViewController,UIScrollViewDelegate {
    
    lazy private var searchController = UISearchController()
    lazy private var receipeArray = [RecipeResult]()
    
    private var searchBarText = ""
    private var reqPageNo:Int = 1
    private var footerView    = UIView()
    private var hasMoreData   = false
    
    @IBOutlet private weak var listingTV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Hello this is branch")
        
        listingTV.tableFooterView = UIView()
        
        listingTV.estimatedRowHeight = 247
        listingTV.rowHeight = UITableView.automaticDimension
        self.listingTV.setEmptyMessage("Search recipe with comma seperated")
        listingTV.separatorStyle = .singleLine
        
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            navigationItem.searchController = controller
            navigationItem.hidesSearchBarWhenScrolling = false
            controller.searchBar.delegate = self
            
            return controller
        })()
        initFooterView()
        
    }
    
    func initFooterView() {
        
        footerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 40.0))
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.tag = 100
        spinner.frame = CGRect(x: UIScreen.main.bounds.width/2-10, y: 5.0, width: 20.0, height: 20.0)
        spinner.hidesWhenStopped = true
        footerView.addSubview(spinner)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        listingTV.tableFooterView = footerView
        if !hasMoreData {
            listingTV.tableFooterView = nil
        }
    }
    
    //MARK: - API
    func getRecipeList(loadFirstTime firstTime:Bool,searchText:String) {
        
        if !Connectivity.isConnectedToInternet {
            listingTV.setEmptyMessage("No internet connection")
        }else{
            
            if firstTime {
                self.startActivityIndicator()
                reqPageNo = 1
                self.listingTV.backgroundView = nil
            }else{
                reqPageNo = reqPageNo + 1
                (footerView.viewWithTag(100) as? UIActivityIndicatorView)?.startAnimating()
            }
            let url = URLConstants.getReceipeListing(with: searchText, pageNumber: reqPageNo).addingPercentEncoding(withAllowedCharacters: .urlAllowed)!
            
            APIHandler.sharedInstance.requestGET(serviceUrl: url, params: nil, success: { (successJson,httpCode) in
                
                self.listingTV.backgroundView = nil
                (self.footerView.viewWithTag(100) as? UIActivityIndicatorView)?.stopAnimating()
                if let responseObject = successJson as? [String:Any]{
                    
                    if firstTime {
                        self.stopActivityIndicator()
                        if let jsonArray = responseObject["results"] as? [[String : Any]]{
                            
                            if jsonArray.count == 0 {
                                self.listingTV.setEmptyMessage("No result")
                                self.receipeArray.removeAll()
                                self.listingTV.reloadData()
                                self.hasMoreData = false
                            }else{
                                self.receipeArray.removeAll()
                                self.decodeArray(jsonArray)
                                self.hasMoreData = true
                            }
                        }
                    }else{
                        if let jsonArray = responseObject["results"] as? [[String : Any]] {
                            
                            if jsonArray.count == 0 {
                                self.reqPageNo = self.reqPageNo - 1
                                self.hasMoreData = false
                            }else{
                                self.decodeArray(jsonArray)
                                self.hasMoreData = true
                            }
                        }
                    }
                }
            }) { (error,errorString,errorJson,httpCode) in
                self.stopActivityIndicator()
                (self.footerView.viewWithTag(100) as? UIActivityIndicatorView)?.stopAnimating()
            }
        }
    }
    
    func decodeArray(_ array:[[String : Any]]) {
        
        let decoder = JSONDecoder()
        for d in array {
            do {
                let seatResultData = try JSONSerialization.data(withJSONObject: d, options: .prettyPrinted)
                let seatResult = try decoder.decode(RecipeResult.self, from: seatResultData)
                self.receipeArray.append(seatResult)
                self.listingTV.reloadData()
            } catch {
                print("decode error")
            }
        }
    }
    
    //MARK: - Actions
    @objc func shareButtonAction(sender:UIButton,event:Any) {
      
        let indexxx = CurrentIndexPath.ofTableView(self.listingTV, event: event, indexpath: self.listingTV)
        
        let controller = UIActivityViewController(activityItems: ["", URL(string:receipeArray[indexxx.row].href ?? "") ?? ""], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
}
extension SearchRecipeVC : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        searchController.dismiss(animated: true)
        searchBarText = searchBar.text ?? ""
        self.getRecipeList(loadFirstTime: true, searchText: searchBarText)
    }
}
extension SearchRecipeVC:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receipeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell") as! RecipeCell
        cell.selectionStyle = .none
        
        cell.titleLabel.text = receipeArray[indexPath.row].title?.filter { !$0.isNewline }
        cell.ingredientsLabel.text = receipeArray[indexPath.row].ingredients
        
        let imageUrl = "\(receipeArray[indexPath.row].thumbnail ?? "")"
        if imageUrl != "" {
            cell.recipeImage.af_setImage(withURL: URL(string: imageUrl)!,placeholderImage:  UIImage(named: "placeholder.png")!)
        }
        if indexPath.row == receipeArray.count - 1{
         
            if hasMoreData {
                self.getRecipeList(loadFirstTime: false, searchText: searchBarText)
                (footerView.viewWithTag(100) as? UIActivityIndicatorView)?.startAnimating()
            }
        }
        cell.shareButton.addTarget(self, action: #selector(shareButtonAction(sender:event:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.openSFSafariVC(WithURL: "\(receipeArray[indexPath.row].href!)")
    }
    
}
