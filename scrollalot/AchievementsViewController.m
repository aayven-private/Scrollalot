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

@interface AchievementsViewController ()

@property (nonatomic, weak) IBOutlet UICollectionView *achievementsCollectionView;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    AchievementCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AchievementCell" forIndexPath:indexPath];
    
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
    
    cell.badgeView.image = badge;
    
    cell.nameLabel.text = achievementName;
    
    cell.layer.borderWidth=1.0f;
    cell.layer.borderColor=[UIColor blackColor].CGColor;
    cell.layer.cornerRadius = 8.0;
    
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
    return CGSizeMake(120, 160);
}

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    AchievementHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"AchievementHeader" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        headerView.titleLabel.text = @"Combos";
    } else if (indexPath.section == 1) {
        headerView.titleLabel.text = @"Routes";
    }
    return headerView;
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
