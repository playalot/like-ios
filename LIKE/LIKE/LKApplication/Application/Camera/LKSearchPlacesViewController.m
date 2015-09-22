//
//  LKSearchPlacesViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/2.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSearchPlacesViewController.h"
#import "LKLocationManager.h"
#import "LKNearPlacesSearch.h"

@interface LKSearchPlacesViewController () <UISearchDisplayDelegate,UISearchBarDelegate>

LC_PROPERTY(strong) LKLocationManager * locationManager;
LC_PROPERTY(strong) LKNearPlacesSearch * placesSearch;

LC_PROPERTY(strong) AMapReGeocode * regeocode;
LC_PROPERTY(strong) CLLocation * location;
LC_PROPERTY(assign) NSInteger page;

LC_PROPERTY(strong) UISearchBar * searchBar;
LC_PROPERTY(strong) UISearchDisplayController * searchController;

LC_PROPERTY(strong) NSMutableArray * datasource;
LC_PROPERTY(strong) NSMutableArray * searchResultDatasource;


@end

@implementation LKSearchPlacesViewController

-(instancetype) init
{
    if (self = [super init]) {
        
        self.locationManager = [[LKLocationManager alloc] init];
        self.placesSearch = [[LKNearPlacesSearch alloc] init];
    }
    
    return self;
}

-(void) buildUI
{
    if ([CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized
         || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)) {
       
        }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){

        [LCUIAlertView showWithTitle:LC_LO(@"提醒") message:LC_LO(@"定位失败，请您打开定位开关后重试。") cancelTitle:LC_LO(@"确定") otherTitle:nil didTouchedBlock:^(NSInteger integerValue) {
                         
         }];
        
        [self performSelector:@selector(dismissOrPopViewController) withObject:nil afterDelay:1];
    }
    
    self.title = LC_LO(@"地点");
    
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft title:LC_LO(@"取消") titleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];

    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    
    UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    searchBar.FIT();
    searchBar.placeholder = LC_LO(@"搜索附近位置");
    searchBar.backgroundColor = [UIColor whiteColor];
    searchBar.barTintColor = [UIColor whiteColor];
    searchBar.tintColor = LKColor.color;
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.delegate = self;
    self.searchBar = searchBar;
    self.tableView.tableHeaderView = searchBar;
    
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsTableView.backgroundView = LCUIBlurView.view;
    self.searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchController.searchResultsTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    for(UIView * subview in self.searchController.searchResultsTableView.subviews) {
        
        if([subview isKindOfClass:[UILabel class]]) {
            
            [(UILabel*)subview setText:@"my custom 'no results' text"];
        }
        
    }

    
    
    @weakly(self);
    
    [self setPullLoaderStyle:LCUIPullLoaderStyleFooter beginRefresh:^(LCUIPullLoaderDiretion diretion) {
       
        @normally(self);
        
        [self loadData:diretion];
    }];
    
    [self loadData:LCUIPullLoaderDiretionTop];
}

-(void) handleNavigationBarButton:(LCUINavigationBarButtonType)type
{
    if (type == LCUINavigationBarButtonTypeLeft) {
        
        [self dismissOrPopViewController];
    }
}

-(void) loadData:(LCUIPullLoaderDiretion)diretion
{
    if (!self.location) {
     
        @weakly(self);
        
        [self.locationManager requestCurrentLocationWithBlock:^(CLLocation *location, AMapReGeocode *regeocode, NSError *error) {
            
            @normally(self);
            
            self.regeocode = regeocode;
            self.location = location;
            
            [self searchNearPlaces:diretion];
        }];
    }
    else{
        
        [self searchNearPlaces:diretion];
    }
}

-(void) searchNearPlaces:(LCUIPullLoaderDiretion)diretion
{
    NSInteger page = _page;
    
    if (diretion == LCUIPullLoaderDiretionBottom) {
        
        page += 1;
    }
    
    @weakly(self);

    [self.placesSearch requestNearPlacesWithLocation:self.location page:page block:^(NSArray *places, NSError *error) {
       
        @normally(self);

        [self.pullLoader endRefresh];
        
        if (error) {
            
            [self showTopMessageErrorHud:error.localizedDescription];
        }
        else{
            
            self.page = page;
            
            if (page == 0) {
                
                AMapPOI * poi = [[AMapPOI alloc] init];
                poi.name = self.regeocode.addressComponent.city;
                poi.address = self.regeocode.formattedAddress;
                
                self.datasource = [places mutableCopy];
                [self.datasource addObject:poi];
            }
            else{
                
                [self.datasource addObjectsFromArray:places];
            }
            
            [self reloadData];
        }
        
    }];
}

-(void) searchPlaceWithName:(NSString *)name
{
    @weakly(self);
    
    [self.placesSearch requestNearPlacesWithLocation:self.location name:name block:^(NSArray *places, NSError *error) {
        
        @normally(self);
        
        if (error) {
            
            [self showTopMessageErrorHud:error.localizedDescription];
        }
        else{
        
            AMapPOI * poi = [[AMapPOI alloc] init];
            poi.name = LC_LO(@"没有找到你的位置？");
            poi.address = [NSString stringWithFormat:@"%@ %@",LC_LO(@"创建新的地点："), name];
            poi.tel = name;
            
            if (places.count == 0) {
                
                self.searchResultDatasource = [NSMutableArray array];
            }
            else{
                
                self.searchResultDatasource = [places mutableCopy];
            }
            
            [self.searchResultDatasource addObject:poi];

            [self.searchDisplayController.searchResultsTableView reloadData];
        }
        
    }];

}

#pragma mark - 

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar.text.length) {
        
        [self searchPlaceWithName:searchBar.text];
    }
    
    [self.searchBar resignFirstResponder];
}

#pragma mark - 

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller NS_DEPRECATED_IOS(3_0,8_0) {
    self.searchResultDatasource = nil;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller NS_DEPRECATED_IOS(3_0,8_0) {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller NS_DEPRECATED_IOS(3_0,8_0)
{
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    for (UIView* v in self.searchDisplayController.searchResultsTableView.subviews) {
        if ([v isKindOfClass: [UILabel class]] &&
            [[(UILabel*)v text] isEqualToString:@"No Results"]) {
            [(UILabel*)v setText:@""];
            break;
        }
    }
    
    return YES;
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchController.searchResultsTableView) {
        
        return self.searchResultDatasource.count;
    }
    
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LCUITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Content"];
    
    if (!cell) {
        
        cell = [[LCUITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Content"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        
        LCUILabel * label = LCUILabel.view;
        label.viewFrameX = 15;
        label.viewFrameY = 12;
        label.viewFrameWidth = self.view.viewFrameWidth - 30;
        label.viewFrameHeight = 15;
        label.font = LK_FONT_B(13);
        label.textColor = LC_RGB(84, 79, 73);
        label.tag = 1000;
        cell.ADD(label);
        
        
        LCUILabel * sublabel = LCUILabel.view;
        sublabel.viewFrameX = 15;
        sublabel.viewFrameY = label.viewBottomY + 5;
        sublabel.viewFrameWidth = self.view.viewFrameWidth - 30;
        sublabel.viewFrameHeight = 15;
        sublabel.font = LK_FONT(10);
        sublabel.textColor = [UIColor lightGrayColor];
        sublabel.tag = 1001;
        cell.ADD(sublabel);
        
        
        UIView * line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
        line.viewFrameWidth = LC_DEVICE_WIDTH;
        line.viewFrameX = 15;
        cell.ADD(line);

    }
    
    LCUILabel * label = cell.FIND(1000);
    LCUILabel * sublabel = cell.FIND(1001);

    AMapPOI * poi = tableView == self.searchController.searchResultsTableView ? self.searchResultDatasource[indexPath.row] : self.datasource[indexPath.row];
    
    label.text = poi.name;
    sublabel.text = poi.address;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AMapPOI * poi = tableView == self.searchController.searchResultsTableView ? self.searchResultDatasource[indexPath.row] : self.datasource[indexPath.row];
    
    
    if ([poi.name isEqualToString:LC_LO(@"没有找到你的位置？")]) {
        
        [LKActionSheet showWithTitle:nil buttonTitles:@[LC_LO(@"创建")] didSelected:^(NSInteger integerValue) {
           
            if (integerValue == 0) {
                
                if (self.didSelected) {
                    self.didSelected(poi.tel, self.location);
                }
                
                [self dismissOrPopViewController];
            }
            
        }];
    }
    else{
        
        if (self.didSelected) {
            self.didSelected(poi.name, self.location);
        }
        
        [self dismissOrPopViewController];
    }

}

@end
