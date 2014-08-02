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
#import "GlobalAppProperties.h"

@interface AchievementsViewController ()

@property (nonatomic, weak) IBOutlet UICollectionView *achievementsCollectionView;
@property (nonatomic, weak) IBOutlet UIButton *okButton;
@property (nonatomic, weak) IBOutlet UIImageView *bgView;
@property (nonatomic, weak) IBOutlet UIButton *gcButton;

@property (nonatomic) NSString *badgesState;

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
        
        self.badgesState = @"combos";
    }
    return self;
}

/*-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}*/

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __block GlobalAppProperties *props = [GlobalAppProperties sharedInstance];
    UIViewController *authView = props.storedGCAuthView;
    if (authView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:authView animated:YES completion:^{
                props.storedGCAuthView = nil;
            }];
        });
    }
    
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = .5;
    pulseAnimation.toValue = [NSNumber numberWithFloat:1.1];
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = FLT_MAX;
    [_gcButton.layer addAnimation:pulseAnimation forKey:nil];
    
    UIPanGestureRecognizer* panSwipeRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanSwipe:)];
    //panSwipeRecognizer.cancelsTouchesInView = NO;
    // Here you can customize for example the minimum and maximum number of fingers required
    panSwipeRecognizer.minimumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panSwipeRecognizer];
    
    if (IS_PHONEPOD5()) {
        [_bgView setImage:[UIImage imageNamed:@"combo_scr_5"]];
    } else {
        [_bgView setImage:[UIImage imageNamed:@"combo_scr_4"]];
    }
    
    /*_achievementsCollectionView.layer.borderWidth = 2.0f;
    _achievementsCollectionView.layer.borderColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1].CGColor;
    _achievementsCollectionView.layer.cornerRadius = 8.0;*/
    
    [_okButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ok_button"]]];
    _okButton.titleLabel.font = [UIFont fontWithName:fontName size:22];
    
    //[_okButton setImage:[UIImage imageNamed:@"ok_button"] forState:UIControlStateNormal];
    //[_okButton setImage:[UIImage imageNamed:@"ok_button_on"] forState:UIControlStateHighlighted];
    
    // Do any additional setup after loading the view from its nib.
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    //_okButton.titleLabel.font = [UIFont fontWithName:fontName size:25];
    
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
    //[self.achievementsCollectionView registerNib:[UINib nibWithNibName:@"AchievementHeader" bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"AchievementHeader"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if ([_badgesState isEqualToString:@"combos"]) {
        //Combos
        NSArray *combos = [_achievementsDict objectForKey:@"combos"];
        if (combos) {
            return combos.count;
        }
    } else if ([_badgesState isEqualToString:@"routes"]) {
        //Routes
        NSArray *routes = [_achievementsDict objectForKey:@"routes"];
        if (routes) {
            return routes.count;
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AchievementCell *cell;
    
    /*if ([_badgesState isEqualToString:@"combos"]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ComboCell" forIndexPath:indexPath];
    } else if ([_badgesState isEqualToString:@"routes"]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AchievementCell" forIndexPath:indexPath];
    }*/
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AchievementCell" forIndexPath:indexPath];
    
    //AchievementCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AchievementCell" forIndexPath:indexPath];
    
    NSArray *dataSource = [_achievementsDict objectForKey:_badgesState];
    
    NSDictionary *cellData = [dataSource objectAtIndex:indexPath.row];
    
    //NSString *achievementId = [cellData objectForKey:@"achievementId"];
    NSString *achievementName = [cellData objectForKey:@"name"];
    NSString *badgeName = [cellData objectForKey:@"badgeName"];
    UIImage *badge = [UIImage imageNamed:badgeName];
    
    /*if ([_badgesState isEqualToString:@"combos"]) {
        ((ComboCell *)cell).badgeView.image = badge;
    } else if ([_badgesState isEqualToString:@"routes"]) {
        ((AchievementCell *)cell).badgeView.image = badge;
        ((AchievementCell *)cell).nameLabel.text = achievementName;
    }*/
    
    cell.badgeView.image = badge;
    //cell.badgeView.image = badge;
    cell.nameLabel.text = achievementName;
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([_badgesState isEqualToString:@"combos"]) {
        //return CGSizeMake(80, 80);
    }
    return CGSizeMake(90, 120);
}

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    /*if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        AchievementHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"AchievementHeader" forIndexPath:indexPath];
        headerView.titleLabel.font = [UIFont fontWithName:fontName size:22];
        if (indexPath.section == 0) {
            headerView.titleLabel.text = @"Combos";
        } else if (indexPath.section == 1) {
            headerView.titleLabel.text = @"Routes";
        }
        return headerView;
    }*/
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

-(IBAction)tableAltered:(id)sender
{
    if ([_badgesState isEqualToString:@"combos"]) {
        _badgesState = @"routes";
        if (IS_PHONEPOD5()) {
            [_bgView setImage:[UIImage imageNamed:@"routes_scr_5"]];
        } else {
            [_bgView setImage:[UIImage imageNamed:@"routes_scr_4"]];
        }
    } else if ([_badgesState isEqualToString:@"routes"]) {
        _badgesState = @"combos";
        if (IS_PHONEPOD5()) {
            [_bgView setImage:[UIImage imageNamed:@"combo_scr_5"]];
        } else {
            [_bgView setImage:[UIImage imageNamed:@"combo_scr_4"]];
        }
    }
    [_achievementsCollectionView reloadData];
}

- (void)handlePanSwipe:(UIPanGestureRecognizer*)recognizer
{
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint vel = [recognizer velocityInView:recognizer.view];

        if (fabs(vel.x) >= fabs(vel.y)) {
            if ([_badgesState isEqualToString:@"combos"]) {
                _badgesState = @"routes";
                if (IS_PHONEPOD5()) {
                    [_bgView setImage:[UIImage imageNamed:@"routes_scr_5"]];
                } else {
                    [_bgView setImage:[UIImage imageNamed:@"routes_scr_4"]];
                }
            } else if ([_badgesState isEqualToString:@"routes"]) {
                _badgesState = @"combos";
                if (IS_PHONEPOD5()) {
                    [_bgView setImage:[UIImage imageNamed:@"combo_scr_5"]];
                } else {
                    [_bgView setImage:[UIImage imageNamed:@"combo_scr_4"]];
                }
            }
            [_achievementsCollectionView reloadData];
        }
    }
}

-(IBAction)gcClicked:(id)sender
{
    //GCManager *gcm = [[GCManager alloc] init];
    //if (!gcm.isEnabled) {
        //[gcm authenticateLocalPlayerShowLoginView:YES];
    //} else {
        GKGameCenterViewController* gameCenterController = [[GKGameCenterViewController alloc] init];
        gameCenterController.viewState = GKGameCenterViewControllerStateAchievements;
        gameCenterController.gameCenterDelegate = self;
        [self presentViewController:gameCenterController animated:YES completion:nil];
    //}
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(IBAction)buttonTouched:(id)sender
{
    [_okButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ok_button_on"]]];
    [_okButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

-(IBAction)buttonReleased:(id)sender
{
    [_okButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ok_button"]]];
    [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

@end
