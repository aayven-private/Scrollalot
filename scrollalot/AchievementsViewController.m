//
//  AchievementsViewController.m
//  scrollalot
//
//  Created by Ivan Borsa on 28/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "AchievementsViewController.h"
#import "AchievementCell.h"
#import "AchievementHeader.h"
#import "ComboManager.h"
#import "RouteManager.h"
#import "ComboCell.h"
#import "Constants.h"

@interface AchievementsViewController ()

@property (nonatomic, weak) IBOutlet UICollectionView *achievementsCollectionView;
@property (nonatomic, weak) IBOutlet UIButton *okButton;

@end

@implementation AchievementsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.achievementsDict = [NSMutableDictionary dictionary];
        self.achievementsCollectionView.backgroundColor = [UIColor clearColor];
        //self.view.backgroundColor = [UIColor lightGrayColor];
        //self.achievementsCollectionView.delegate = self;
        //self.achievementsCollectionView.dataSource = self;
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _achievementsCollectionView.layer.borderWidth = 2.0f;
    _achievementsCollectionView.layer.borderColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1].CGColor;
    _achievementsCollectionView.layer.cornerRadius = 8.0;
    
    // Do any additional setup after loading the view from its nib.
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    _okButton.titleLabel.font = [UIFont fontWithName:fontName size:25];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ComboManager *cm = [ComboManager sharedManager];
        RouteManager *rm = [[RouteManager alloc] init];
        
        [self.achievementsDict setObject:[cm getAchievedCombos_dictionary] forKey:@"combos"];
        [self.achievementsDict setObject:[rm getAchievedRoutes_dictionary] forKey:@"routes"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_achievementsCollectionView reloadData];
        });
    });
}

-(void)viewWillAppear:(BOOL)animated{
    [self.achievementsCollectionView registerNib:[UINib nibWithNibName:@"AchievementCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"AchievementCell"];
    [self.achievementsCollectionView registerNib:[UINib nibWithNibName:@"ComboCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ComboCell"];
    //[self.achievementsCollectionView registerNib:[UINib nibWithNibName:@"AchievementHeader" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"AchievementHeader"];
    [self.achievementsCollectionView registerNib:[UINib nibWithNibName:@"AchievementHeader" bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"AchievementHeader"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        //Combos
        NSArray *combos = [_achievementsDict objectForKey:@"combos"];
        if (combos) {
            return combos.count;
        }
    } else if (section == 1) {
        //Routes
        NSArray *routes = [_achievementsDict objectForKey:@"routes"];
        if (routes) {
            return routes.count;
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ComboCell" forIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AchievementCell" forIndexPath:indexPath];
    }
    
    //AchievementCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AchievementCell" forIndexPath:indexPath];
    
    NSArray *dataSource = nil;
    
    if (indexPath.section == 0) {
        dataSource = [_achievementsDict objectForKey:@"combos"];
    } else if (indexPath.section == 1) {
        dataSource = [_achievementsDict objectForKey:@"routes"];
    }
    
    NSDictionary *cellData = [dataSource objectAtIndex:indexPath.row];
    
    //NSString *achievementId = [cellData objectForKey:@"achievementId"];
    NSString *achievementName = [cellData objectForKey:@"name"];
    NSString *badgeName = [cellData objectForKey:@"badgeName"];
    UIImage *badge = [UIImage imageNamed:badgeName];
    
    if (indexPath.section == 0) {
        ((ComboCell *)cell).badgeView.image = badge;
    } else if (indexPath.section == 1) {
        ((AchievementCell *)cell).badgeView.image = badge;
        ((AchievementCell *)cell).nameLabel.text = achievementName;
    }
    
    cell.layer.borderWidth=1.0f;
    cell.layer.borderColor=[UIColor darkGrayColor].CGColor;
    cell.layer.cornerRadius = 8.0;
    
    CALayer *layer = [cell layer];
    [layer setMasksToBounds:NO];
    [layer setRasterizationScale:[[UIScreen mainScreen] scale]];
    [layer setShouldRasterize:YES];
    [layer setShadowColor:[[UIColor whiteColor] CGColor]];
    //[layer setShadowOffset:CGSizeMake(1.0f,1.5f)];
    [layer setShadowRadius:8.0f];
    [layer setShadowOpacity:0.2f];
    [layer setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:layer.cornerRadius] CGPath]];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return CGSizeMake(80, 80);
    }
    return CGSizeMake(80, 120);
}

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        AchievementHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"AchievementHeader" forIndexPath:indexPath];
        headerView.titleLabel.font = [UIFont fontWithName:fontName size:22];
        if (indexPath.section == 0) {
            headerView.titleLabel.text = @"Combos";
        } else if (indexPath.section == 1) {
            headerView.titleLabel.text = @"Routes";
        }
        return headerView;
    }
    return nil;
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)okClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
