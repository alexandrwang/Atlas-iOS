//
//  CMAddressSearchViewController.h
//  ComfortMe
//
//  Created by Lucy Guo on 9/6/14.
//  Copyright (c) 2014 Stephen Greco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPGooglePlacesAutocompleteQuery;

@protocol CMAddressSearchDelegate <NSObject>

@required
- (void) setSelectedAddress: (NSString*)address;

@end

@interface CMAddressSearchViewController : UIViewController <UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {
    BOOL shouldBeginEditing;
    SPGooglePlacesAutocompleteQuery *searchQuery;
    NSArray *searchResultsPlaces;
}

@property     id<CMAddressSearchDelegate> delegate;

@end
