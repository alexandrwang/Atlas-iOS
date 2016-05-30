//
//  ATLPillKeyboardViewController.m
//  Pods
//
//  Created by Jesse Chand on 5/21/16.
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
    self.customJustifiedFlowLayout.sectionInset = UIEdgeInsetsMake(14, 12, 14, 10);
    self.customJustifiedFlowLayout.horizontalCellPadding = 10.0f;

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
    self.dataSourceArray = @[@"Primary Care",
                             @"Dentist",
                             @"Therapist",
                             @"Physical Therapist",
                             @"Eye Doctor",
                             @"Dermatologist",
                             @"Ear, Nose, Throat",
                             @"Psychiatrist",
                             @"Orthopedic Surgeon",
                             @"OB-GYN",
                             @"Massage Therapist",
                             @"Other"
                             ];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewDidLayoutSubviews {
    _collectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)configureCell:(ATLPillKeyboardCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    [cell setLabelText:self.dataSourceArray[indexPath.row % self.dataSourceArray.count]];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self.delegate keyboard:self didSelectCell:cell];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 12;
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