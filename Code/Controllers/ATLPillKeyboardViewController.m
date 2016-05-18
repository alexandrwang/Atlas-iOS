//
//  SpecialistButtonsViewController.m
//  Pods
//
//  Created by Lucy Guo on 4/23/16.
//
//

#import "ATLPillKeyboardViewController.h"
#import "ATLPillKeyboardCollectionViewCell.h"
#import "ERJustifiedFlowLayout.h"

@interface ATLPillKeyboardViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) ATLPillKeyboardCollectionViewCell *sizingCell;
@property (nonatomic, strong) NSArray *dataSourceArray;
@property (strong, nonatomic) ERJustifiedFlowLayout *customJustifiedFlowLayout;

@end

@implementation ATLPillKeyboardViewController {
}


- (id)init {
    self = [super init];

    self.customJustifiedFlowLayout = [[ERJustifiedFlowLayout alloc] init];
    self.customJustifiedFlowLayout.horizontalJustification = FlowLayoutHorizontalJustificationLeft;
    self.customJustifiedFlowLayout.sectionInset = UIEdgeInsetsMake(14, 14, 0, 14);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:self.customJustifiedFlowLayout];
    [self.collectionView registerClass:[ATLPillKeyboardCollectionViewCell class] forCellWithReuseIdentifier:@"ATLPillKeyboardCollectionViewCell"];
    
    self.sizingCell = [[ATLPillKeyboardCollectionViewCell alloc] init];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];

    self.collectionView.backgroundColor = [UIColor whiteColor];

    return self;
}

- (void)loadView {
    [super loadView];
    self.dataSourceArray = @[@"Doctor", @"Dentist", @"Therapist", @"Optometrist", @"Physical Therapy", @"OB-GYN"];
}

- (void)viewDidLayoutSubviews {
    _collectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)configureCell:(ATLPillKeyboardCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.labelText = self.dataSourceArray[indexPath.row % self.dataSourceArray.count];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ATLPillKeyboardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ATLPillKeyboardCollectionViewCell" forIndexPath:indexPath];
    
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:self.sizingCell forIndexPath:indexPath];
    
    return [self.sizingCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
}


@end
