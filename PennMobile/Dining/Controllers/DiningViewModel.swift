//
//  DiningViewModel.swift
//  PennMobile
//
//  Created by Josh Doman on 1/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

protocol DiningViewModelDelegate: DiningBalanceRefreshable {
    func handleSelection(for venue: DiningVenue)
}

class DiningViewModel: NSObject {
    let ordering: [DiningVenue.VenueType] = [.dining, .retail]
    var venues: [DiningVenue.VenueType : [DiningVenue]] = DiningDataStore.shared.getSectionedVenues()
    var balance: DiningBalance?
    
    let balancesHeader = "Dining Balance"
    let diningHeader = "Dining Halls"
    let retailHeader = "Retail Dining"
    
    weak var transactionCellDelegate: TransactionCellDelegate?
    
    var delegate: DiningViewModelDelegate?
    var showActivity = false
    
    internal let headerView = "headerView"
    internal let diningCell = "diningCell"
    internal let diningBalanceCell = "diningBalanceCell"
    
    func refresh() {
        self.venues = DiningDataStore.shared.getSectionedVenues()
    }
    
    func getType(forSection section: Int) -> DiningVenue.VenueType {
        return ordering[section - 1]
    }
    
    func getVenues(forSection section: Int) -> [DiningVenue] {
        let venueType = getType(forSection: section)
        return venues[venueType] ?? []
    }
    
    func getVenue(for indexPath: IndexPath) -> DiningVenue {
        return getVenues(forSection: indexPath.section)[indexPath.row]
    }
}

// MARK: - UITableViewDataSource
extension DiningViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return ordering.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : getVenues(forSection: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: diningBalanceCell, for: indexPath) as! DiningBalanceCell
            cell.selectionStyle = .none
            cell.diningBalance = balance
            cell.transactionCellDelegate = transactionCellDelegate
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: diningCell, for: indexPath) as! DiningCell
        cell.venue = getVenue(for: indexPath)
        return cell
    }
    
    func registerHeadersAndCells(for tableView: UITableView) {
        tableView.register(DiningCell.self, forCellReuseIdentifier: diningCell)
        tableView.register(DiningBalanceCell.self, forCellReuseIdentifier: diningBalanceCell)
        tableView.register(DiningHeaderView.self, forHeaderFooterViewReuseIdentifier: headerView)
    }
}

// MARK: - UITableViewDelegate
extension DiningViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerView) as! DiningHeaderView
            view.label.text = balancesHeader
            view.state = showActivity ? .loading : .refresh
            view.delegate = self.delegate
            return view
        } else {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerView) as! DiningHeaderView
            
            let headerTitle: String
            let type = getType(forSection: section)
            switch type {
            case .dining, .retail, .unknown:
                headerTitle = type.fullDisplayName
            }
            
            view.label.text = headerTitle
            view.state = .normal
            view.delegate = nil
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? DiningBalanceCell.cellHeight : DiningCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return DiningHeaderView.headerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > 0 {
            let venue = getVenue(for: indexPath)
            delegate?.handleSelection(for: venue)
        }
    }
}
