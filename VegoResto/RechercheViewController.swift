//
//  RechercheViewController.swift
//  VegoResto
//
//  Created by Laurent Nicolas on 30/03/2016.
//  Copyright © 2016 Nicolas Laurent. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import DGElasticPullToRefresh

class RechercheViewController: VGAbstractFilterViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var varIB_searchBar: UISearchBar?
    @IBOutlet weak var varIB_tableView: UITableView?

    var afficherUniquementFavoris = false

    let TAG_CELL_LABEL_NAME = 501
    let TAG_CELL_LABEL_ADRESS = 502
    let TAG_CELL_LABEL_DISTANCE = 505
    let TAG_CELL_LABEL_VILLE = 506
    let TAG_CELL_IMAGE_LOC = 507

    let TAG_CELL_VIEW_CATEGORIE_COLOR = 510
    let TAG_CELL_IMAGE_FAVORIS = 520

    var array_restaurants: [Restaurant] = [Restaurant]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.varIB_searchBar?.backgroundImage = UIImage()

        self.loadRestaurantsWithWord(key: nil)

        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = COLOR_ORANGE
        self.varIB_tableView?.dg_addPullToRefreshWithActionHandler({ () -> Void in
            // Add your logic here
            // Do not forget to call dg_stopLoading() at the end
            (self.parent as? NavigationAccueilViewController)?.updateData(forced: true) { (_) in
                self.varIB_tableView?.dg_stopLoading()
            }

        }, loadingView: loadingView)

        self.varIB_tableView?.dg_setPullToRefreshFillColor( UIColor(hexString: "EDEDED") )
        self.varIB_tableView?.dg_setPullToRefreshBackgroundColor(UIColor.white)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch StoryboardSegue.Main(rawValue: segue.identifier! )! {

        case .segueToDetail:
            // Prepare for your custom segue transition

            if let detailRestaurantVC: DetailRestaurantViewController = segue.destination as? DetailRestaurantViewController {

                if let index = self.varIB_tableView?.indexPathForSelectedRow?.row {

                    detailRestaurantVC.current_restaurant = self.array_restaurants[index]
                }

            }

        default :
            break
        }

    }

    // MARK: UITableViewDelegate Delegate

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let current_restaurant: Restaurant = self.array_restaurants[indexPath.row]

        let reuseIdentifier = current_restaurant.favoris.boolValue ? "cell_restaurant_identifer_favoris_on" : "cell_restaurant_identifer_favoris_off"

        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? MGSwipeTableCell

        if cell == nil {
            cell = MGSwipeTableCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)

        }

        // Configure the cell...

        let label_name = cell?.viewWithTag(TAG_CELL_LABEL_NAME) as? UILabel
        let label_adress = cell?.viewWithTag(TAG_CELL_LABEL_ADRESS) as? UILabel
        let label_distance = cell?.viewWithTag(TAG_CELL_LABEL_DISTANCE) as? UILabel
        let label_ville = cell?.viewWithTag(TAG_CELL_LABEL_VILLE) as? UILabel
        let image_loc = cell?.viewWithTag(TAG_CELL_IMAGE_LOC) as? UIImageView

        label_name?.text = current_restaurant.name
        label_adress?.text = current_restaurant.address
        label_ville?.text = current_restaurant.ville

        let view_color_categorie = cell?.viewWithTag(TAG_CELL_VIEW_CATEGORIE_COLOR)
        let imageview_favoris = cell?.viewWithTag(TAG_CELL_IMAGE_FAVORIS) as? UIImageView

        var imageSwipe: UIImage = Asset.imgFavorisOff.image

        switch current_restaurant.categorie() {

        case CategorieRestaurant.Vegan :
            view_color_categorie?.backgroundColor = COLOR_VERT
            if current_restaurant.favoris.boolValue {
                imageview_favoris?.image = Asset.imgFavoris0.image
            } else {
                imageSwipe = Asset.imgFavorisOn0.image
            }

        case CategorieRestaurant.Végétarien :
            view_color_categorie?.backgroundColor = COLOR_VIOLET
            if current_restaurant.favoris.boolValue {
                imageview_favoris?.image = Asset.imgFavoris1.image
            } else {
                imageSwipe = Asset.imgFavorisOn1.image
            }

        case CategorieRestaurant.VeganFriendly :
            view_color_categorie?.backgroundColor = COLOR_BLEU
            if current_restaurant.favoris.boolValue {
                imageview_favoris?.image = Asset.imgFavoris2.image
            } else {
                imageSwipe = Asset.imgFavorisOn2.image
            }

        }

        let bt1 = MGSwipeButton(title: "", icon: imageSwipe, backgroundColor: COLOR_GRIS_BACKGROUND ) { (_) -> Bool in

            current_restaurant.favoris = !(current_restaurant.favoris.boolValue) as NSNumber

            self.afficherUniquementFavoris ? self.updateData() : self.varIB_tableView?.reloadData()

            return true
        }

        bt1.buttonWidth = 110

        cell?.rightButtons = [ bt1]
        cell?.rightSwipeSettings.transition = .static
        cell?.rightSwipeSettings.threshold = 10
        cell?.rightExpansion.buttonIndex = 0
        cell?.rightExpansion.fillOnTrigger = true

        label_distance?.text = ""
        image_loc?.isHidden = true

        if current_restaurant.distance > 0 && current_restaurant.distance < 1000 {

            label_distance?.text = String(Int(current_restaurant.distance)) + " m"
            image_loc?.isHidden = false

        } else if current_restaurant.distance >= 1000 {

            label_distance?.text = String(format: "%.1f Km", current_restaurant.distance/1000.0 )
            image_loc?.isHidden = false
        }

        return cell!

    }

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.array_restaurants.count
    }

    // MARK: UISearchBar Delegate

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        let textField: UITextField? = self.findTextFieldInView( view: searchBar)

        if let _textField = textField {
            _textField.enablesReturnKeyAutomatically = false
        }

    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {

        searchBar.resignFirstResponder()

        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        self.loadRestaurantsWithWord(key: searchText)
        self.varIB_tableView?.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        self.loadRestaurantsWithWord(key: nil)
        self.varIB_tableView?.reloadData()
    }

    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {

        searchBar.resignFirstResponder()
    }

    func findTextFieldInView(view: UIView) -> UITextField? {

        if view is UITextField {

            return view as? UITextField

        }

        for subview: UIView in view.subviews {

            let textField: UITextField? = self.findTextFieldInView(view: subview)

            if let _textField = textField {

                return _textField

            }

        }

        return nil

    }

    func loadRestaurantsWithWord(key: String?) {

        self.array_restaurants = UserData.sharedInstance.getRestaurants()

        if self.afficherUniquementFavoris {

            self.array_restaurants = self.array_restaurants.flatMap({ (current_restaurant: Restaurant) -> Restaurant? in

                if current_restaurant.favoris.boolValue == true {

                    return current_restaurant
                }

                return nil

            })

        }

        self.varIB_tableView?.reloadData()

        if let _key = key?.lowercased() {

            if _key.characters.count > 3 {

                self.array_restaurants = self.array_restaurants.flatMap({ (current_restaurant: Restaurant) -> Restaurant? in

                    if let clean_name: String = current_restaurant.name?.lowercased().folding(options : .diacriticInsensitive, locale: Locale.current ) {

                        if clean_name.contains(_key) {
                            return current_restaurant
                        }

                    }

                    if let clean_adress: String = current_restaurant.address?.lowercased().folding(options: .diacriticInsensitive, locale: Locale.current ) {

                        if clean_adress.contains(_key) {
                            return current_restaurant
                        }
                    }

                    return nil

                })

            }

        }

            self.array_restaurants = self.array_restaurants.flatMap({ (currentResto: Restaurant) -> Restaurant? in

                if self.filtre_categorie_VeganFriendly_active && self.filtre_categorie_Vegetarien_active && self.filtre_categorie_Vegan_active {

                    return currentResto

                } else {

                    switch currentResto.categorie() {

                    case CategorieRestaurant.Vegan :

                        if self.filtre_categorie_Vegan_active {
                            return currentResto
                        }

                    case CategorieRestaurant.Végétarien :

                        if self.filtre_categorie_Vegetarien_active {
                            return currentResto
                        }

                    case CategorieRestaurant.VeganFriendly :

                        if self.filtre_categorie_VeganFriendly_active {
                            return currentResto
                        }

                    }

                    return nil

                }

            })

    }

    func update_resultats_for_user_location() {

        if let location = UserData.sharedInstance.location {

            for restaurant in self.array_restaurants {

                restaurant.update_distance_avec_localisation( seconde_localisation: location )
            }

            self.array_restaurants.sort(by: { (restaurantA, restaurantB) -> Bool in

                restaurantA.distance < restaurantB.distance

            })

            self.varIB_tableView?.reloadData()

            self.varIB_tableView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)

        }

    }

    func updateDataAfterDelay() {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.updateData()
        }

    }

    override func updateData() {

        Debug.log(object: "RechercheViewController - updateData")

        self.loadRestaurantsWithWord(key: self.varIB_searchBar?.text)
        self.varIB_tableView?.reloadData()
        self.varIB_tableView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }

}

// -----------------------------------------
// MARK: Protocol - UIScrollViewDelegate
// -----------------------------------------

extension RechercheViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 50 {
            self.view.endEditing(true)
        }
    }
}
