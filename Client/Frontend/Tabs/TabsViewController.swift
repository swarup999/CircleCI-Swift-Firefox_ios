// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Alamofire

class TabsViewController: UITableViewController
{
    private var TABS_CELL_IDENTIFIER = "TABS_CELL"

    var tabsResponse: TabsResponse?
    // TODO: Move this to the authenticator when its available.
    var favicons: Favicons = BasicFavicons();
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        favicons = BasicFavicons();
        
        tableView.sectionFooterHeight = 0
        //tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: TABS_CELL_IDENTIFIER)
    }

    func reloadData() {
        Alamofire.request(.GET, "https://syncapi-dev.sateh.com/1.0/tabs")
            .authenticate(user: "sarentz+syncapi@mozilla.com", password: "q1w2e3r4")
            .responseJSON { (request, response, data, error) in
                self.tabsResponse = parseTabsResponse(data)
                dispatch_async(dispatch_get_main_queue()) {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
        }
    }
    
    func refresh() {
        reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let r = tabsResponse {
            return r.clients.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let r = tabsResponse {
            return r.clients[section].tabs.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(TABS_CELL_IDENTIFIER, forIndexPath: indexPath) as UITableViewCell;

        if let tab = tabsResponse?.clients[indexPath.section].tabs[indexPath.row] {
            // TODO: We need better async image loading here
            favicons.getForUrl(NSURL(string: tab.url)!, options: nil, callback: { (icon: Favicon) -> Void in
                if var img = icon.img {
                    cell.imageView.image = createMockFavicon(img);
                    cell.setNeedsLayout()
                }
            });
            cell.textLabel.text = tab.title
        }
        
        cell.textLabel.font = UIFont(name: "FiraSans-SemiBold", size: 13)
        cell.textLabel.textColor = UIColor.darkGrayColor()
        cell.indentationWidth = 20
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let objects = UINib(nibName: "TabsViewControllerHeader", bundle: nil).instantiateWithOwner(nil, options: nil)
        let view = objects[0] as? UIView
        
        if let label = view?.viewWithTag(1) as? UILabel {
            if let response = tabsResponse {
                let client = response.clients[section]
                label.text = client.name
            }
        }
        
        return view
    }
    
//    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let objects = UINib(nibName: "TabsViewControllerHeader", bundle: nil).instantiateWithOwner(nil, options: nil)
//        if let view = objects[0] as? UIView {
//            if let label = view.viewWithTag(1) as? UILabel {
//                // TODO: More button
//            }
//        }
//        return view
//    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if let tab = tabsResponse?.clients[indexPath.section].tabs[indexPath.row] {
            UIApplication.sharedApplication().openURL(NSURL(string: tab.url)!)
        }
    }
}
