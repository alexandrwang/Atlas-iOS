//
//  SpecialistButtonsViewController.m
//  Pods
//
//  Created by Lucy Guo on 4/23/16.
//
//

#import "SpecialistButtonsViewController.h"
#import "SpecialistKeyboardCollectionViewCell.h"
#import "ERJustifiedFlowLayout.h"

@interface SpecialistButtonsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) SpecialistKeyboardCollectionViewCell *sizingCell;
@property (nonatomic, strong) NSArray *dataSourceArray;
@property (strong, nonatomic) ERJustifiedFlowLayout *customJustifiedFlowLayout;

@end

@implementation SpecialistButtonsViewController


- (id)init {
    self = [super init];
    
    
    
    self.customJustifiedFlowLayout = [[ERJustifiedFlowLayout alloc] init];
    self.customJustifiedFlowLayout.horizontalJustification = FlowLayoutHorizontalJustificationLeft;
//    self.customJustifiedFlowLayout.horizontalCellPadding = 5;
    self.customJustifiedFlowLayout.sectionInset = UIEdgeInsetsMake(20, 14, 0, 14);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:self.customJustifiedFlowLayout];
    
    
    
    [self.collectionView registerClass:[SpecialistKeyboardCollectionViewCell class] forCellWithReuseIdentifier:@"SpecialistKeyboardCollectionViewCell"];
    
    self.sizingCell = [[SpecialistKeyboardCollectionViewCell alloc] init];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.frame = self.view.frame;
    
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];

    
    return self;
}

- (void)loadView {
    // Do any additional setup after loading the view, typically from a nib.
    [super loadView];
    
    
    
    
    
    self.dataSourceArray = @[@"Doctors", @"Dentist", @"Therapist", @"Optometrist", @"Physical Therapy", @"OB-GYN"];
    
    // ERJustifiedFlowLayout customization point-- set horizontal justification type and cell padding here.
    // Vertical justification is not yet supported. It is not necessary to set the sectionInset property.
    
    
    
}

-(void)configureCell:(SpecialistKeyboardCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    cell.labelText = self.dataSourceArray[indexPath.row % self.dataSourceArray.count];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 7;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SpecialistKeyboardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SpecialistKeyboardCollectionViewCell" forIndexPath:indexPath];
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:self.sizingCell forIndexPath:indexPath];
    
    return [self.sizingCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
}


@end
