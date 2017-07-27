////
///  ArtistInviteDetailController.swift
//

class ArtistInviteDetailController: StreamableViewController {
    override func trackerName() -> String? { return "ArtistInvite" }
    override func trackerProps() -> [String: Any]? { return ["id": artistInviteId] }
    override func trackerStreamInfo() -> (String, String?)? { return nil }

    let artistInviteId: String
    var artistInvite: ArtistInvite?

    private var _mockScreen: ArtistInviteDetailScreenProtocol?
    var screen: ArtistInviteDetailScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! ArtistInviteDetailScreen }
    }
    var generator: ArtistInviteDetailGenerator!

    init(artistInviteId: String) {
        self.artistInviteId = artistInviteId
        super.init(nibName: nil, bundle: nil)

        generator = ArtistInviteDetailGenerator(
            artistInviteId: artistInviteId,
            currentUser: currentUser,
            destination: self)
        streamViewController.streamKind = generator.streamKind
        streamViewController.pagingEnabled = false
        streamViewController.reloadClosure = { [weak self] in self?.generator?.load(reload: true) }
        streamViewController.initialLoadClosure = { [weak self] in self?.generator.load() }
    }

    convenience init(artistInvite: ArtistInvite) {
        self.init(artistInviteId: artistInvite.id)
        self.setPrimary(jsonable: artistInvite)
        generator.artistInvite = artistInvite
   }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didSetCurrentUser() {
        generator.currentUser = currentUser
        super.didSetCurrentUser()
    }

    override func loadView() {
        let screen = ArtistInviteDetailScreen()
        screen.delegate = self

        let backItem = UIBarButtonItem.backChevronWithTarget(self, action: #selector(backTapped))
        elloNavigationItem.leftBarButtonItem = backItem
        elloNavigationItem.fixNavBarItemPadding()
        screen.navigationItem = elloNavigationItem

        self.view = screen
        viewContainer = screen.streamContainer
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    fileprivate func updateInsets() {
        updateInsets(navBar: screen.navigationBar)
    }

    override func showNavBars() {
        super.showNavBars()
        positionNavBar(screen.navigationBar, visible: true, withConstraint: screen.navigationBarTopConstraint)
        updateInsets()
    }

    override func hideNavBars() {
        super.hideNavBars()
        positionNavBar(screen.navigationBar, visible: false, withConstraint: screen.navigationBarTopConstraint)
        updateInsets()
    }

}

extension ArtistInviteDetailController: StreamDestination {

    var pagingEnabled: Bool {
        get { return streamViewController.pagingEnabled }
        set { streamViewController.pagingEnabled = newValue }
    }

    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping Block) {
        streamViewController.replacePlaceholder(type: type, items: items, completion: completion)
        streamViewController.doneLoading()
    }

    func setPlaceholders(items: [StreamCellItem]) {
        streamViewController.clearForInitialLoad()
        streamViewController.appendStreamCellItems(items)
    }

    func setPrimary(jsonable: JSONAble) {
        guard let artistInvite = jsonable as? ArtistInvite else { return }

        self.artistInvite = artistInvite
        title = artistInvite.title
    }

    func setPagingConfig(responseConfig: ResponseConfig) {
        streamViewController.responseConfig = responseConfig
    }

    func primaryJSONAbleNotFound() {
        self.showGenericLoadFailure()
        self.streamViewController.doneLoading()
    }

}

extension ArtistInviteDetailController: ArtistInviteResponder {
    func tappedArtistInviteSubmissionsButton() {
        streamViewController.scrollTo(placeholderType: .artistInviteSubmissions, animated: true)
    }

    func tappedArtistInviteSubmitButton() {
        let vc = OmnibarViewController()
        vc.artistInviteId = artistInviteId
        vc.currentUser = currentUser
        vc.onPostSuccess { _ in
            _ = self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension ArtistInviteDetailController: ArtistInviteDetailScreenDelegate {}