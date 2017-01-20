//
//  ZLPeoplePickerViewController.m
//  ZLPeoplePickerViewControllerDemo
//
//  Created by Zhixuan Lai on 11/4/14.
//  Copyright (c) 2014 Zhixuan Lai. All rights reserved.
//

#import "ZLPeoplePickerViewController.h"
#import "ZLResultsTableViewController.h"
#import <UIImageView+Utils.h>

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "ZLAddressBook.h"
#import "APContact+Sorting.h"

#if __IPHONE_8_0
@interface ZLPeoplePickerViewController () <
ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate,
ABNewPersonViewControllerDelegate, ABUnknownPersonViewControllerDelegate,
UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
#else
@interface ZLPeoplePickerViewController () <
ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate,
ABNewPersonViewControllerDelegate, ABUnknownPersonViewControllerDelegate,
UISearchBarDelegate,UISearchDisplayDelegate>
#endif


@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic, strong) id searchController;
@property (strong, nonatomic)
    ZLResultsTableViewController *resultsTableViewController;

// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@end

@implementation ZLPeoplePickerViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
        [self setup];
    }
    return self;
}


- (void)setup {
    _numberOfSelectedPeople = ZLNumSelectionNone;
    self.filedMask = ZLContactFieldDefault;
}

+ (void)initializeAddressBook {
    [[ZLAddressBook sharedInstance] loadContacts:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _resultsTableViewController = [[ZLResultsTableViewController alloc] init];
    if (IOS8AFTER) {
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        searchBar.placeholder = @"搜索";
        [searchBar sizeToFit];
        UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
        searchController.searchResultsDataSource = self;
        searchController.searchResultsDelegate = self;
        searchController.delegate = self;
        self.searchController = searchController;
        self.tableView.tableHeaderView = searchBar;
        searchController.searchBar.delegate = self;


    }else{
        _searchController = [[UISearchController alloc]
                             initWithSearchResultsController:self.resultsTableViewController];
        UISearchController *tmpSearch = (UISearchController *)_searchController;
        tmpSearch.searchBar.backgroundImage = [UIImageView createImageWithColor:kColorLine];
        tmpSearch.searchResultsUpdater = self;
        [tmpSearch.searchBar sizeToFit];
        self.tableView.tableHeaderView = tmpSearch.searchBar;
        tmpSearch.delegate = self;
        tmpSearch.searchBar.delegate = self;
    }
    
    
    // we want to be the delegate for our filtered table so
    // didSelectRowAtIndexPath is called for both tables
    self.resultsTableViewController.tableView.delegate = self;
    self.definesPresentationContext =
        YES; // know where you want UISearchController to be displayed

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlAction:)
                  forControlEvents:UIControlEventValueChanged];
//
//    // Uncomment the following line to preserve selection between presentations.
//    // self.clearsSelectionOnViewWillAppear = NO;
//
//    self.navigationItem.title = @"Contacts";
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
//        initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
//                             target:self
//                             action:@selector(showNewPersonViewController)];
//
    [self refreshControlAction:self.refreshControl];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(addressBookDidChangeNotification:)
               name:ZLAddressBookDidChangeNotification
             object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        if (IOS8AFTER) {
            UISearchDisplayController *tmpSearch = (UISearchDisplayController *)_searchController;
            tmpSearch.active = self.searchControllerWasActive;
        }else{
            UISearchController *tmpSearch = (UISearchController *)_searchController;
            tmpSearch.active = self.searchControllerWasActive;
        }
        _searchControllerWasActive = NO;

        if (self.searchControllerSearchFieldWasFirstResponder) {
            if (IOS8AFTER) {
                UISearchDisplayController *tmpSearch = (UISearchDisplayController *)_searchController;
                [tmpSearch.searchBar becomeFirstResponder];
            }else{
                UISearchController *tmpSearch = (UISearchController *)_searchController;
                [tmpSearch.searchBar becomeFirstResponder];
            }
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (![parent isEqual:self.parentViewController]) {
        [self invokeReturnDelegate];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:ZLAddressBookDidChangeNotification
                object:nil];
}

#pragma mark - Action
+ (instancetype)presentPeoplePickerViewControllerForParentViewController:
                    (UIViewController *)parentViewController {
    UINavigationController *navController =
        [[UINavigationController alloc] init];
    ZLPeoplePickerViewController *peoplePicker =
        [[ZLPeoplePickerViewController alloc] init];
    [navController pushViewController:peoplePicker animated:NO];
    peoplePicker.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                             target:peoplePicker
                             action:@selector(doneButtonAction:)];
    peoplePicker.delegate = parentViewController;
    [parentViewController presentViewController:navController
                                       animated:YES
                                     completion:nil];
    return peoplePicker;
}

- (void)doneButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self invokeReturnDelegate];
}

- (void)refreshControlAction:(UIRefreshControl *)aRefreshControl {
    [aRefreshControl beginRefreshing];
    [self reloadData:^(BOOL succeeded, NSError *error) {
        [aRefreshControl endRefreshing];
    }];
}

- (void)addressBookDidChangeNotification:(NSNotification *)note {
    [self performSelector:@selector(reloadData) withObject:nil];
}

- (void)reloadData {
    [self reloadData:nil];
}

- (void)reloadData:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    __weak __typeof(self) weakSelf = self;
    if ([ZLAddressBook sharedInstance].contacts.count > 0) {
        [weakSelf
            setPartitionedContactsWithContacts:[ZLAddressBook sharedInstance]
                                                   .contacts];
        [weakSelf.tableView reloadData];
    }
    [[ZLAddressBook sharedInstance]
        loadContacts:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [weakSelf setPartitionedContactsWithContacts:
                              [ZLAddressBook sharedInstance].contacts];
                [weakSelf.tableView reloadData];
                if (completionBlock) {
                    completionBlock(YES, nil);
                }
            } else {
                if (completionBlock) {
                    completionBlock(NO, nil);
                }
            }
        }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar {
    [aSearchBar resignFirstResponder];
    if (IOS8AFTER) {
        [self setPartitionedContactsWithContacts:[ZLAddressBook sharedInstance]
         .contacts];
        [self.tableView reloadData];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar {
    [aSearchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
    [aSearchBar setShowsCancelButton:NO animated:YES];
    if (IOS8AFTER) {
        [self setPartitionedContactsWithContacts:[ZLAddressBook sharedInstance]
         .contacts];
        [self.tableView reloadData];
    }
}

- (void)onSearchResult{
    UISearchDisplayController *searchController = (UISearchDisplayController *)_searchController;
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [[self.partitionedContacts
                                      valueForKeyPath:@"@unionOfArrays.self"] mutableCopy];
    
    // strip out all the leading and trailing spaces
    NSString *strippedStr =
    [searchText stringByTrimmingCharactersInSet:
     [NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedStr.length > 0) {
        searchItems = [strippedStr componentsSeparatedByString:@" "];
    }
    // build all the "AND" expressions for each value in the searchString
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems) {
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        // TODO: match phone number matching
        
        // name field matching
        NSPredicate *finalPredicate = [NSPredicate
                                       predicateWithFormat:@"compositeName CONTAINS[c] %@", searchString];
        [searchItemsPredicate addObject:finalPredicate];
        
        NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"ANY SELF.emails CONTAINS[c] %@",
         searchString];
        [searchItemsPredicate addObject:predicate];
        
        predicate = [NSPredicate
                     predicateWithFormat:@"ANY SELF.addresses.street CONTAINS[c] %@",
                     searchString];
        [searchItemsPredicate addObject:predicate];
        predicate = [NSPredicate
                     predicateWithFormat:@"ANY SELF.addresses.city CONTAINS[c] %@",
                     searchString];
        [searchItemsPredicate addObject:predicate];
        predicate = [NSPredicate
                     predicateWithFormat:@"ANY SELF.addresses.zip CONTAINS[c] %@",
                     searchString];
        [searchItemsPredicate addObject:predicate];
        predicate = [NSPredicate
                     predicateWithFormat:@"ANY SELF.addresses.country CONTAINS[c] %@",
                     searchString];
        [searchItemsPredicate addObject:predicate];
        predicate = [NSPredicate
                     predicateWithFormat:
                     @"ANY SELF.addresses.countryCode CONTAINS[c] %@", searchString];
        [searchItemsPredicate addObject:predicate];
        
        //        NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc]
        //        init];
        //        [numFormatter setNumberStyle:NSNumberFormatterNoStyle];
        //        NSNumber *targetNumber = [numFormatter
        //        numberFromString:searchString];
        //        if (targetNumber != nil) {   // searchString may not convert
        //        to a number
        //            predicate = [NSPredicate predicateWithFormat:@"ANY
        //            SELF.sanitizePhones CONTAINS[c] %@", searchString];
        //            [searchItemsPredicate addObject:predicate];
        //        }
        
        // at this OR predicate to our master AND predicate
        NSCompoundPredicate *orMatchPredicates =
        (NSCompoundPredicate *)[NSCompoundPredicate
                                orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    NSCompoundPredicate *finalCompoundPredicate = nil;
    
    // match up the fields of the Product object
    finalCompoundPredicate = (NSCompoundPredicate *)
    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    
    searchResults = [[searchResults
                      filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    [self setPartitionedContactsWithContacts:searchResults];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    APContact *contact = [self contactForRowAtIndexPath:indexPath];

    if (![tableView isEqual:self.tableView]) {
        if (IOS8AFTER) {
            UISearchDisplayController *tmpSearch = (UISearchDisplayController *)_searchController;
            contact = [(ZLResultsTableViewController *)
                       tmpSearch.searchContentsController
                       contactForRowAtIndexPath:indexPath];
        }else{
            UISearchController *tmpSearch = (UISearchController *)_searchController;
            contact = [(ZLResultsTableViewController *)
                       tmpSearch.searchResultsController
                       contactForRowAtIndexPath:indexPath];
        }

    }

    if (![self shouldEnableCellforContact:contact]) {
        return;
    }

    if (self.delegate &&
        [self.delegate
            respondsToSelector:@selector(peoplePickerViewController:
                                                    didSelectPerson:)]) {
        [self.delegate peoplePickerViewController:self
                                  didSelectPerson:contact.recordID];
    }

    if ([self.selectedPeople containsObject:contact.recordID]) {
        [self.selectedPeople removeObject:contact.recordID];
    } else {
        if (self.selectedPeople.count < self.numberOfSelectedPeople) {
            [self.selectedPeople addObject:contact.recordID];
        }
    }

    //    NSLog(@"heree");

    [tableView reloadData];
    [self.tableView reloadData];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:
            (UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [[self.partitionedContacts
        valueForKeyPath:@"@unionOfArrays.self"] mutableCopy];

    // strip out all the leading and trailing spaces
    NSString *strippedStr =
        [searchText stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceCharacterSet]];

    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedStr.length > 0) {
        searchItems = [strippedStr componentsSeparatedByString:@" "];
    }
    // build all the "AND" expressions for each value in the searchString
    NSMutableArray *andMatchPredicates = [NSMutableArray array];

    for (NSString *searchString in searchItems) {
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];

        // TODO: match phone number matching

        // name field matching
        NSPredicate *finalPredicate = [NSPredicate
            predicateWithFormat:@"compositeName CONTAINS[c] %@", searchString];
        [searchItemsPredicate addObject:finalPredicate];

        NSPredicate *predicate =
            [NSPredicate predicateWithFormat:@"ANY SELF.emails CONTAINS[c] %@",
                                             searchString];
        [searchItemsPredicate addObject:predicate];

        predicate = [NSPredicate
            predicateWithFormat:@"ANY SELF.addresses.street CONTAINS[c] %@",
                                searchString];
        [searchItemsPredicate addObject:predicate];
        predicate = [NSPredicate
            predicateWithFormat:@"ANY SELF.addresses.city CONTAINS[c] %@",
                                searchString];
        [searchItemsPredicate addObject:predicate];
        predicate = [NSPredicate
            predicateWithFormat:@"ANY SELF.addresses.zip CONTAINS[c] %@",
                                searchString];
        [searchItemsPredicate addObject:predicate];
        predicate = [NSPredicate
            predicateWithFormat:@"ANY SELF.addresses.country CONTAINS[c] %@",
                                searchString];
        [searchItemsPredicate addObject:predicate];
        predicate = [NSPredicate
            predicateWithFormat:
                @"ANY SELF.addresses.countryCode CONTAINS[c] %@", searchString];
        [searchItemsPredicate addObject:predicate];

        //        NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc]
        //        init];
        //        [numFormatter setNumberStyle:NSNumberFormatterNoStyle];
        //        NSNumber *targetNumber = [numFormatter
        //        numberFromString:searchString];
        //        if (targetNumber != nil) {   // searchString may not convert
        //        to a number
        //            predicate = [NSPredicate predicateWithFormat:@"ANY
        //            SELF.sanitizePhones CONTAINS[c] %@", searchString];
        //            [searchItemsPredicate addObject:predicate];
        //        }

        // at this OR predicate to our master AND predicate
        NSCompoundPredicate *orMatchPredicates =
            (NSCompoundPredicate *)[NSCompoundPredicate
                orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }

    NSCompoundPredicate *finalCompoundPredicate = nil;

    // match up the fields of the Product object
    finalCompoundPredicate = (NSCompoundPredicate *)
        [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];

    searchResults = [[searchResults
        filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];

    // hand over the filtered results to our search results table
    if (IOS8AFTER) {
        UISearchDisplayController *tmpSearch = (UISearchDisplayController *)_searchController;
        ZLResultsTableViewController *tableController =
        (ZLResultsTableViewController *)
        tmpSearch.searchContentsController;
        tableController.filedMask = self.filedMask;
        tableController.selectedPeople = self.selectedPeople;
        [tableController setPartitionedContactsWithContacts:searchResults];
        [tableController.tableView reloadData];
    }else {
        UISearchController *tmpSearch = (UISearchController *)_searchController;
        ZLResultsTableViewController *tableController =
        (ZLResultsTableViewController *)
        tmpSearch.searchResultsController;
        tableController.filedMask = self.filedMask;
        tableController.selectedPeople = self.selectedPeople;
        [tableController setPartitionedContactsWithContacts:searchResults];
        [tableController.tableView reloadData];
    }
}

#pragma mark - ABAdressBookUI

#pragma mark Create a new person
- (void)showNewPersonViewController {
    ABNewPersonViewController *picker =
        [[ABNewPersonViewController alloc] init];
    picker.newPersonViewDelegate = self;

    UINavigationController *navigation =
        [[UINavigationController alloc] initWithRootViewController:picker];
    [self presentViewController:navigation animated:YES completion:nil];
}
#pragma mark ABNewPersonViewControllerDelegate methods
// Dismisses the new-person view controller.
- (void)newPersonViewController:
            (ABNewPersonViewController *)newPersonViewController
       didCompleteWithNewPerson:(ABRecordRef)person {
    [self dismissViewControllerAnimated:YES completion:NULL];
    if (self.delegate &&
        [self.delegate
         respondsToSelector:@selector(newPersonViewControllerDidCompleteWithNewPerson:)]) {
            [self.delegate newPersonViewControllerDidCompleteWithNewPerson:person];
         }
}

#pragma mark - ()
- (void)invokeReturnDelegate {
    if (self.delegate &&
        [self.delegate
            respondsToSelector:@selector(peoplePickerViewController:
                                        didReturnWithSelectedPeople:)]) {
        [self.delegate peoplePickerViewController:self
                      didReturnWithSelectedPeople:[self.selectedPeople copy]];
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView{
    UISearchDisplayController *tmpSearch = (UISearchDisplayController *)_searchController;
    BaseViewController *base = (BaseViewController *)tmpSearch.searchContentsController;
    [tmpSearch.searchContentsController.view bringSubviewToFront:base.customNavigationView];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self onSearchResult];
    return YES;
}



@end
