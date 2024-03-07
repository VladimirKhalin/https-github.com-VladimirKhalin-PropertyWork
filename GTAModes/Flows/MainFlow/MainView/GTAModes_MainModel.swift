
import Foundation
import RealmSwift
import Combine

protocol MainModelNavigationHandler: AnyObject {
    
    func mainModelDidRequestToGameSelection(_ model: GTAModes_MainModel)
    func mainModelDidRequestToChecklist(_ model: GTAModes_MainModel)
    func mainModelDidRequestToMap(_ model: GTAModes_MainModel)
    func mainModelDidRequestToModes(_ model: GTAModes_MainModel)
    func mainModelDidRequestToModesInfo(_ model: GTAModes_MainModel)
}

final class GTAModes_MainModel {
    
    public var hideSpiner: (() -> Void)?
    
    var reloadData: AnyPublisher<Void, Never> {
        reloadDataSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    var menuItems: [MainItem] = []
    
    private let navigationHandler: MainModelNavigationHandler
    private let reloadDataSubject = PassthroughSubject<Void, Never>()
    private let defaults = UserDefaults.standard
    var notificationToken: NotificationToken?
    
    init(
        navigationHandler: MainModelNavigationHandler
    ) {
        self.navigationHandler = navigationHandler
        
        GTAModes_DBManager.shared.delegate = self
        GTAModes_DBManager.shared.gta_setupDropBox()
    }
    
    public func gta_selectedItems(index: Int) {
        if index == 0 {
            navigationHandler.mainModelDidRequestToGameSelection(self)
        }
        
        if index == 1 {
            navigationHandler.mainModelDidRequestToChecklist(self)
        }
        
        if index == 2 {
            navigationHandler.mainModelDidRequestToMap(self)
        }
        
        if index == 3 {
            navigationHandler.mainModelDidRequestToModes(self)
        }
       
        if index == 4 {
            navigationHandler.mainModelDidRequestToModesInfo(self)
        }
    }

    func gta_fetchData() {
        if menuItems.count != 5 {
            do {
                let realm = try Realm()
                let menuItem = realm.objects(MainItemObject.self)
                let valueList = menuItem.filter { $0.rawTypeItem == "main"}
                let trueValueList = valueList.map { $0.lightweightRepresentation }
                
                trueValueList.forEach { [weak self] value in
                    guard let self = self else { return }
                    
                    self.menuItems.append(value)
                }
                reloadDataSubject.send()
                hideSpiner?()
            } catch {
                print("Error saving data to Realm: \(error)")
            }
        }
    }
    
}

extension GTAModes_MainModel: GTA_DropBoxManagerDelegate {
    
    func gta_isReadyMain() {
        gta_fetchData()
    }
    
    func gta_isReadyGameList() { }
    
    func gta_isReadyGameCodes() { }
    
    func gta_isReadyMissions() { }
    
    func gta_isReadyGTA5Mods() { }
    
    
}