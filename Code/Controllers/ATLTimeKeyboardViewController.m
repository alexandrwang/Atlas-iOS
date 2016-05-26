#import "ATLTimeKeyboardViewController.h"
#import "ATLTimeKeyboardCollectionViewCell.h"
#import "ATLButton.h"
#import "ATLMessagingUtilities.h"

@interface ATLTimeKeyboardViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) ATLTimeKeyboardCollectionViewCell *sizingCell;
@property (nonatomic, strong) NSArray *dataSourceArray;

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@end

const CGFloat kBottomBarHeight = 52.0f;
const CGFloat kHorizontalSpacing = 13.0f;
const CGFloat kVerticalSpacing = 8.0f;

@implementation ATLTimeKeyboardViewController {
    ATLButton *_importButton;
    ATLButton *_addButton;
    NSMutableArray *_selectedIndices;
    UIImageView *_gradientView;
}

- (id)init {
    self = [super init];
    self.view.backgroundColor = [UIColor whiteColor];

    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.flowLayout.minimumLineSpacing = 1.0f;
    self.flowLayout.minimumInteritemSpacing = 1.0f;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:self.flowLayout];
    _collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[ATLTimeKeyboardCollectionViewCell class] forCellWithReuseIdentifier:@"ATLTimeKeyboardCollectionViewCell"];
    self.sizingCell = [[ATLTimeKeyboardCollectionViewCell alloc] init];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.alwaysBounceVertical = YES;

    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];

    NSBundle *resourcesBundle = ATLResourcesBundle();
    UIImage *image = [UIImage imageNamed:@"gradient" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    _gradientView = [[UIImageView alloc] initWithImage:image];
    _gradientView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_gradientView];

    _importButton = [[ATLButton alloc] init];
    [_importButton setTitle:@"Import Calendar" forState:UIControlStateNormal];
    [_importButton setTitleColor:[UIColor colorWithRed:0.33 green:0.73 blue:0.88 alpha:1.0] forState:UIControlStateNormal];
    [self.view addSubview:_importButton];

    _addButton = [[ATLButton alloc] init];
    [_addButton setTitle:@"Add Alternative Dates" forState:UIControlStateNormal];
    [_addButton setTitleColor:[UIColor colorWithRed:0.33 green:0.73 blue:0.88 alpha:1.0] forState:UIControlStateNormal];
    [self.view addSubview:_addButton];

    _selectedIndices = [[NSMutableArray alloc] init];
    return self;
}

- (void)viewDidLayoutSubviews {
    _collectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - kBottomBarHeight + 10);
    _importButton.frame = CGRectMake(kHorizontalSpacing,
                                     self.view.bounds.size.height - kBottomBarHeight + kVerticalSpacing,
                                     150, kBottomBarHeight - kVerticalSpacing * 2);
    _addButton.frame = CGRectMake(CGRectGetMaxX(_importButton.frame) + kHorizontalSpacing,
                                  self.view.bounds.size.height - kBottomBarHeight + kVerticalSpacing,
                                  self.view.bounds.size.width - kHorizontalSpacing * 3 - CGRectGetWidth(_importButton.frame),
                                  kBottomBarHeight - kVerticalSpacing * 2);
    _gradientView.frame = CGRectMake(0, self.view.bounds.size.height - 90, self.view.bounds.size.width, 90);
}

- (void)loadView {
    // Do any additional setup after loading the view, typically from a nib.
    [super loadView];

    self.dataSourceArray = @[@"8:00 - 9:00 AM",   @"9:00 - 10:00 AM", @"10:00 - 11:00 AM",
                             @"11:00 - 12:00 PM", @"12:00 - 1:00 PM", @"1:00 - 2:00 PM",
                             @"2:00 - 3:00 PM",   @"3:00 - 4:00 PM",  @"4:00 - 5:00 PM",
                             @"5:00 - 6:00 PM",   @"6:00 - 7:00 PM",  @"7:00 - 8:00 PM",
                             @"8:00 - 9:00 PM"];
}

- (void)configureCell:(ATLTimeKeyboardCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.stringLabel.text = self.dataSourceArray[indexPath.row % self.dataSourceArray.count];
    if ([_selectedIndices containsObject:@(indexPath.row)]) {
        [cell markSelected:YES];
    } else {
        [cell markSelected:NO];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ATLTimeKeyboardCollectionViewCell *cell = (ATLTimeKeyboardCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    if ([_selectedIndices containsObject:@(indexPath.row)]) {
        [_selectedIndices removeObject:@(indexPath.row)];
        [cell markSelected:NO];
    } else {
        [_selectedIndices addObject:@(indexPath.row)];
        [cell markSelected:YES];
    }

    NSMutableArray *times = [[NSMutableArray alloc] init];
    for (NSNumber *num in _selectedIndices) {
        [times addObject:self.dataSourceArray[num.integerValue]];
    }
    self.selection = [times copy];
    [self.delegate keyboard:self withType:ATLKeyboardTypeTime didUpdateSelection:self.selection];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 13;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ATLTimeKeyboardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ATLTimeKeyboardCollectionViewCell" forIndexPath:indexPath];
    
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.view.bounds.size.width - 3) / 3, (self.view.bounds.size.height - kBottomBarHeight) / 4);
}


@end
