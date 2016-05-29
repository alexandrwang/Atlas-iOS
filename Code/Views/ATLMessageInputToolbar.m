//
//  ATLUIMessageInputToolbar.m
//  Atlas
//
//  Created by Kevin Coleman on 9/18/14.
//  Copyright (c) 2015 Layer. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
#import "ATLMessageInputToolbar.h"
#import "ATLConstants.h"
#import "ATLMediaAttachment.h"
#import "ATLMessagingUtilities.h"

NSString *const ATLMessageInputToolbarDidChangeHeightNotification = @"ATLMessageInputToolbarDidChangeHeightNotification";

@interface ATLMessageInputToolbar () <UITextViewDelegate>

@property (nonatomic) NSArray *mediaAttachments;
@property (nonatomic, copy) NSAttributedString *attributedStringForMessageParts;
@property (nonatomic) CGFloat textViewMaxHeight;
@property (nonatomic) BOOL firstAppearance;

@property (nonatomic) UITextView *dummyTextView;
@property (nonatomic) UIView *hairlineView;
@property (nonatomic) UIView *buttonBarView;
@property (nonatomic) UIButton *keyboardButton;

@end

@implementation ATLMessageInputToolbar

NSString *const ATLMessageInputToolbarAccessibilityLabel = @"Message Input Toolbar";
NSString *const ATLMessageInputToolbarTextInputView = @"Message Input Toolbar Text Input View";
NSString *const ATLMessageInputToolbarCameraButton  = @"Message Input Toolbar Camera Button";
NSString *const ATLMessageInputToolbarLocationButton  = @"Message Input Toolbar Location Button";
NSString *const ATLMessageInputToolbarSendButton  = @"Message Input Toolbar Send Button";

// Compose View Margin Constants
static CGFloat const ATLLeftButtonHorizontalMargin = 14.0f;
static CGFloat const ATLButtonSpacing = 22.0f;
static CGFloat const ATLRightButtonHorizontalMargin = 14.0f;
static CGFloat const ATLVerticalMargin = 7.0f;

// Compose View Button Constants
static CGFloat const ATLLeftAccessoryButtonWidth = 40.0f;
static CGFloat const ATLRightAccessoryButtonDefaultWidth = 46.0f;
static CGFloat const ATLRightAccessoryButtonPadding = 5.3f;
static CGFloat const ATLButtonHeight = 28.0f;

static CGFloat const ATLButtonBarHeight = 44.0f;

+ (void)initialize
{
    ATLMessageInputToolbar *proxy = [self appearance];
    proxy.rightAccessoryButtonActiveColor = ATLBlueColor();
    UIColor *disabledColor = ATLBlueColor();
    proxy.rightAccessoryButtonDisabledColor = [disabledColor colorWithAlphaComponent:0.5f];
    proxy.rightAccessoryButtonFont = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.accessibilityLabel = ATLMessageInputToolbarAccessibilityLabel;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        // The button bar contains the keyboard button, plus button, back button and send button.
        // It sits below the text input view.
        self.buttonBarView = [[UIView alloc] init];
        [self addSubview:self.buttonBarView];

        NSBundle *resourcesBundle = ATLResourcesBundle();
        self.leftAccessoryImage = [UIImage imageNamed:@"custom_inactive" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
        UIImage *keyboardImage = [UIImage imageNamed:@"keyboard_inactive" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
        self.rightAccessoryButton.backgroundColor = [UIColor redColor];
        self.displaysRightAccessoryImage = YES;
        self.firstAppearance = YES;

        // Left accessory button (plus button)
        self.leftAccessoryButton = [[UIButton alloc] init];
        self.leftAccessoryButton.contentMode = UIViewContentModeScaleAspectFit;
        [self.leftAccessoryButton setImage:self.leftAccessoryImage forState:UIControlStateNormal];
        [self.leftAccessoryButton addTarget:self action:@selector(leftAccessoryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonBarView addSubview:self.leftAccessoryButton];

        // Keyboard button
        self.keyboardButton = [[UIButton alloc] init];
        self.keyboardButton.contentMode = UIViewContentModeScaleAspectFit;
        [self.keyboardButton setImage:keyboardImage forState:UIControlStateNormal];
        [self.keyboardButton addTarget:self action:@selector(keyboardButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonBarView addSubview:self.keyboardButton];

        // Go Back Button
        self.goBackButton = [[UIButton alloc] init];
        self.goBackButton.hidden = YES;
        self.goBackButton.contentMode = UIViewContentModeScaleAspectFit;
        [self.goBackButton setTitle:@"Go Back" forState:UIControlStateNormal];
        [self.goBackButton addTarget:self action:@selector(goBackButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonBarView addSubview:self.goBackButton];

        // Right accessory button (send / next button)
        self.rightAccessoryButton = [[UIButton alloc] init];
        [self.rightAccessoryButton addTarget:self action:@selector(rightAccessoryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonBarView addSubview:self.rightAccessoryButton];
        [self configureRightAccessoryButtonState];

        // Text input view:
        self.textInputView = [[ATLMessageComposeTextView alloc] init];
        self.textInputView.accessibilityLabel = ATLMessageInputToolbarTextInputView;
        self.textInputView.delegate = self;
        self.textInputView.layer.borderColor = ATLGrayColor().CGColor;
        self.textInputView.layer.borderWidth = 0;
        self.textInputView.layer.cornerRadius = 5.0f;
        self.textInputView.autocorrectionType = UITextAutocorrectionTypeNo;
        [self addSubview:self.textInputView];
        
        self.verticalMargin = ATLVerticalMargin;
        
        // Calling sizeThatFits: or contentSize on the displayed UITextView causes the cursor's position to momentarily appear out of place and prevent scrolling to the selected range. So we use another text view for height calculations.
        self.dummyTextView = [[ATLMessageComposeTextView alloc] init];
        self.maxNumberOfLines = 8;

        self.backgroundColor = [UIColor whiteColor];
        self.barTintColor = [UIColor whiteColor];
        
        self.clipsToBounds = YES;
        self.translucent = NO;

        self.hairlineView = [[UIView alloc] init];
        [self.hairlineView setUserInteractionEnabled:NO];
        [self.hairlineView setBackgroundColor:[UIColor colorWithWhite:0.93f alpha:1.0f]];
        [self addSubview:self.hairlineView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.firstAppearance) {
        [self configureRightAccessoryButtonState];
        self.firstAppearance = NO;
    }
    
    // set the font for the dummy text view as well
    self.dummyTextView.font = self.textInputView.font;
    
    // We layout the views manually since using Auto Layout seems to cause issues in this context (i.e. an auto height resizing text view in an input accessory view) especially with iOS 7.1.
    CGRect frame = self.frame;
    CGRect keyboardButtonFrame = self.keyboardButton.frame;
    CGRect leftButtonFrame = self.leftAccessoryButton.frame;
    CGRect goBackButtonFrame = self.goBackButton.frame;
    CGRect rightButtonFrame = self.rightAccessoryButton.frame;
    CGRect textViewFrame = self.textInputView.frame;

    keyboardButtonFrame.size.width = (self.keyboardButton ? ATLLeftAccessoryButtonWidth : 0);
    leftButtonFrame.size.width = (self.keyboardButton ? ATLLeftAccessoryButtonWidth : 0);
    goBackButtonFrame.size = [_goBackButton sizeThatFits:CGSizeZero];
    rightButtonFrame.size = [_rightAccessoryButton sizeThatFits:CGSizeZero];
    rightButtonFrame.size.width = 50.0f;

    // This makes the input accessory view work with UISplitViewController to manage the frame width.
    if (self.containerViewController) {
        CGRect windowRect = [self.containerViewController.view.superview convertRect:self.containerViewController.view.frame toView:nil];
        frame.size.width = windowRect.size.width;
        frame.origin.x = windowRect.origin.x;
    }

    keyboardButtonFrame.size.height = ATLButtonHeight;
    keyboardButtonFrame.origin.x = ATLLeftButtonHorizontalMargin;
    leftButtonFrame.size.height = ATLButtonHeight;
    leftButtonFrame.origin.x = CGRectGetMaxX(keyboardButtonFrame) + ATLButtonSpacing;
    goBackButtonFrame.size.height = ATLButtonHeight;
    goBackButtonFrame.origin.x = CGRectGetMaxX(leftButtonFrame) + ATLButtonSpacing;

    rightButtonFrame.size.height = ATLButtonHeight;
    rightButtonFrame.origin.x = CGRectGetWidth(frame) - CGRectGetWidth(rightButtonFrame) - ATLRightButtonHorizontalMargin;

    textViewFrame.origin.x = ATLLeftButtonHorizontalMargin - 2.0f;
    textViewFrame.origin.y = self.verticalMargin;
    textViewFrame.size.width = self.bounds.size.width - ATLRightButtonHorizontalMargin * 2;

    self.dummyTextView.attributedText = self.textInputView.attributedText;
    CGSize fittedTextViewSize = [self.dummyTextView sizeThatFits:CGSizeMake(CGRectGetWidth(textViewFrame), MAXFLOAT)];
    textViewFrame.size.height = ceil(MIN(fittedTextViewSize.height, self.textViewMaxHeight));

    CGFloat textViewBarHeight = (CGRectGetHeight(textViewFrame) + self.verticalMargin * 2);
    self.buttonBarView.frame = CGRectMake(0, textViewBarHeight, self.bounds.size.width, ATLButtonBarHeight);

    frame.size.height = textViewBarHeight + self.buttonBarView.frame.size.height;
    frame.origin.y -= frame.size.height - CGRectGetHeight(self.frame);

    leftButtonFrame.origin.y = (ATLButtonBarHeight - leftButtonFrame.size.height) / 2;
    keyboardButtonFrame.origin.y = (ATLButtonBarHeight - keyboardButtonFrame.size.height) / 2;
    goBackButtonFrame.origin.y = (ATLButtonBarHeight - goBackButtonFrame.size.height) / 2;
    rightButtonFrame.origin.y = (ATLButtonBarHeight - rightButtonFrame.size.height) / 2;
    
    BOOL heightChanged = CGRectGetHeight(textViewFrame) != CGRectGetHeight(self.textInputView.frame);

    self.leftAccessoryButton.frame = leftButtonFrame;
    self.keyboardButton.frame = keyboardButtonFrame;
    self.goBackButton.frame = goBackButtonFrame;
    self.rightAccessoryButton.frame = rightButtonFrame;
    self.textInputView.frame = textViewFrame;

    CGFloat hairlineHeight = (1.0f / [[UIScreen mainScreen] nativeScale]);
    self.hairlineView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, hairlineHeight);

    // Setting one's own frame like this is a no-no but seems to be the lesser of evils when working around the layout issues mentioned above.
    self.frame = frame;

    if (heightChanged) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ATLMessageInputToolbarDidChangeHeightNotification object:self];
    }
}

- (void)paste:(id)sender
{
    NSData *imageData = [[UIPasteboard generalPasteboard] dataForPasteboardType:ATLPasteboardImageKey];
    if (imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        ATLMediaAttachment *mediaAttachment = [ATLMediaAttachment mediaAttachmentWithImage:image
                                                                                  metadata:nil
                                                                             thumbnailSize:ATLDefaultThumbnailSize];
        [self insertMediaAttachment:mediaAttachment withEndLineBreak:YES];
    }
}

#pragma mark - Public Methods

- (void)switchToNoKeyboard {
    NSBundle *resourcesBundle = ATLResourcesBundle();
    self.leftAccessoryImage = [UIImage imageNamed:@"custom_inactive" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    UIImage *keyboardImage = [UIImage imageNamed:@"keyboard_inactive" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    [self.keyboardButton setImage:keyboardImage forState:UIControlStateNormal];
}

- (void)switchToCustomKeyboard {
    NSBundle *resourcesBundle = ATLResourcesBundle();
    self.leftAccessoryImage = [UIImage imageNamed:@"custom_active" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    UIImage *keyboardImage = [UIImage imageNamed:@"keyboard_inactive" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    [self.keyboardButton setImage:keyboardImage forState:UIControlStateNormal];
}

- (void)switchToDefaultKeyboard {
    NSBundle *resourcesBundle = ATLResourcesBundle();
    self.leftAccessoryImage = [UIImage imageNamed:@"custom_inactive" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    UIImage *keyboardImage = [UIImage imageNamed:@"keyboard_active" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    [self.keyboardButton setImage:keyboardImage forState:UIControlStateNormal];
}

- (void)setMaxNumberOfLines:(NSUInteger)maxNumberOfLines
{
    _maxNumberOfLines = maxNumberOfLines;
    self.textViewMaxHeight = self.maxNumberOfLines * self.textInputView.font.lineHeight;
    [self setNeedsLayout];
}

- (void)insertMediaAttachment:(ATLMediaAttachment *)mediaAttachment withEndLineBreak:(BOOL)endLineBreak;
{
    UITextView *textView = self.textInputView;

    NSMutableAttributedString *attributedString = [textView.attributedText mutableCopy];
    NSAttributedString *lineBreak = [[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSFontAttributeName: self.textInputView.font}];
    if (attributedString.length > 0 && ![textView.text hasSuffix:@"\n"]) {
        [attributedString appendAttributedString:lineBreak];
    }

    NSMutableAttributedString *attachmentString = (mediaAttachment.mediaMIMEType == ATLMIMETypeTextPlain) ? [[NSAttributedString alloc] initWithString:mediaAttachment.textRepresentation] : [[NSAttributedString attributedStringWithAttachment:mediaAttachment] mutableCopy];
    [attributedString appendAttributedString:attachmentString];
    if (endLineBreak) {
        [attributedString appendAttributedString:lineBreak];
    }
    [attributedString addAttribute:NSFontAttributeName value:textView.font range:NSMakeRange(0, attributedString.length)];
    if (textView.textColor) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:textView.textColor range:NSMakeRange(0, attributedString.length)];
    }
    textView.attributedText = attributedString;
    if ([self.inputToolBarDelegate respondsToSelector:@selector(messageInputToolbarDidType:)]) {
        [self.inputToolBarDelegate messageInputToolbarDidType:self];
    }
    [self setNeedsLayout];
    [self configureRightAccessoryButtonState];
}

- (NSArray *)mediaAttachments
{
    NSAttributedString *attributedString = self.textInputView.attributedText;
    if (!_mediaAttachments || ![attributedString isEqualToAttributedString:self.attributedStringForMessageParts]) {
        self.attributedStringForMessageParts = attributedString;
        _mediaAttachments = [self mediaAttachmentsFromAttributedString:attributedString];
    }
    return _mediaAttachments;
}

- (void)setLeftAccessoryImage:(UIImage *)leftAccessoryImage
{
    _leftAccessoryImage = leftAccessoryImage;
    [self.leftAccessoryButton setImage:leftAccessoryImage  forState:UIControlStateNormal];
}

- (void)setRightAccessoryImage:(UIImage *)rightAccessoryImage
{
    _rightAccessoryImage = rightAccessoryImage;
    [self.rightAccessoryButton setImage:rightAccessoryImage forState:UIControlStateNormal];
}

- (void)setRightAccessoryButtonActiveColor:(UIColor *)rightAccessoryButtonActiveColor
{
    _rightAccessoryButtonActiveColor = rightAccessoryButtonActiveColor;
    [self.rightAccessoryButton setTitleColor:rightAccessoryButtonActiveColor forState:UIControlStateNormal];
    [self.goBackButton setTitleColor:rightAccessoryButtonActiveColor forState:UIControlStateNormal];
}

- (void)setRightAccessoryButtonDisabledColor:(UIColor *)rightAccessoryButtonDisabledColor
{
    _rightAccessoryButtonDisabledColor = rightAccessoryButtonDisabledColor;
    [self.rightAccessoryButton setTitleColor:rightAccessoryButtonDisabledColor forState:UIControlStateDisabled];
    [self.goBackButton setTitleColor:rightAccessoryButtonDisabledColor forState:UIControlStateDisabled];
}

- (void)setRightAccessoryButtonFont:(UIFont *)rightAccessoryButtonFont
{
    _rightAccessoryButtonFont = rightAccessoryButtonFont;
    [self.rightAccessoryButton.titleLabel setFont:rightAccessoryButtonFont];
    [self.goBackButton.titleLabel setFont:rightAccessoryButtonFont];
}

#pragma mark - Actions

- (void)leftAccessoryButtonTapped
{
    [self.inputToolBarDelegate messageInputToolbar:self didTapLeftAccessoryButton:self.leftAccessoryButton];
}

- (void)keyboardButtonTapped
{
    [self.inputToolBarDelegate messageInputToolbar:self didTapKeyboardButton:self.keyboardButton];
}

- (void)goBackButtonTapped
{
    [self layoutSubviews];
    [self.inputToolBarDelegate messageInputToolbar:self didTapGoBackButton:self.goBackButton];
}

- (void)rightAccessoryButtonTapped
{
    [self acceptAutoCorrectionSuggestion];
    if ([self.inputToolBarDelegate respondsToSelector:@selector(messageInputToolbarDidEndTyping:)]) {
        [self.inputToolBarDelegate messageInputToolbarDidEndTyping:self];
    }
    [self.inputToolBarDelegate messageInputToolbar:self didTapRightAccessoryButton:self.rightAccessoryButton];
    if (self.textInputView.isEditable) {
        self.textInputView.text = @"";
    }
    [self setNeedsLayout];
    self.mediaAttachments = nil;
    self.attributedStringForMessageParts = nil;
    [self configureRightAccessoryButtonState];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.inputToolBarDelegate messageInputToolbar:self didTapInputView:self.textInputView];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.rightAccessoryButton.imageView) {
        [self configureRightAccessoryButtonState];
    }
    
    if (textView.text.length > 0 && [self.inputToolBarDelegate respondsToSelector:@selector(messageInputToolbarDidType:)]) {
        [self.inputToolBarDelegate messageInputToolbarDidType:self];
    } else if (textView.text.length == 0 && [self.inputToolBarDelegate respondsToSelector:@selector(messageInputToolbarDidEndTyping:)]) {
        [self.inputToolBarDelegate messageInputToolbarDidEndTyping:self];
    }
    
    [self setNeedsLayout];

    // Workaround for iOS 7.1 not scrolling bottom line into view when entering text. Note that in textViewDidChangeSelection: if the selection to the bottom line is due to entering text then the calculation of the bottom content offset won't be accurate since the content size hasn't yet been updated. Content size has been updated by the time this method is called so our calculation will work.
    NSRange end = NSMakeRange(textView.text.length, 0);
    if (NSEqualRanges(textView.selectedRange, end)) {
        textView.contentSize = CGSizeMake(textView.frame.size.width, textView.frame.size.height);
        CGPoint bottom = CGPointMake(0, fabs(textView.contentSize.height - CGRectGetHeight(textView.frame)));
        [textView setContentOffset:bottom animated:NO];

    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    // Workaround for iOS 7.1 not scrolling bottom line into view. Note that this only works for a selection change not due to text entry (in other words e.g. when using an external keyboard's bottom arrow key). The workaround in textViewDidChange: handles selection changes due to text entry.
    NSRange end = NSMakeRange(textView.text.length, 0);
    if (NSEqualRanges(textView.selectedRange, end)) {
        textView.contentSize = CGSizeMake(textView.frame.size.width, textView.frame.size.height);
        CGPoint bottom = CGPointMake(0, fabs(textView.contentSize.height - CGRectGetHeight(textView.frame)));
        [textView setContentOffset:bottom animated:NO];
        return;
    }

}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    [self layoutSubviews];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    return YES;
}

#pragma mark - Helpers

- (NSArray *)mediaAttachmentsFromAttributedString:(NSAttributedString *)attributedString
{
    NSMutableArray *mediaAttachments = [NSMutableArray new];
    [attributedString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id attachment, NSRange range, BOOL *stop) {
        if ([attachment isKindOfClass:[ATLMediaAttachment class]]) {
            ATLMediaAttachment *mediaAttachment = (ATLMediaAttachment *)attachment;
            [mediaAttachments addObject:mediaAttachment];
            return;
        }
        NSAttributedString *attributedSubstring = [attributedString attributedSubstringFromRange:range];
        NSString *substring = attributedSubstring.string;
        NSString *trimmedSubstring = [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmedSubstring.length == 0) {
            return;
        }
        ATLMediaAttachment *mediaAttachment = [ATLMediaAttachment mediaAttachmentWithText:trimmedSubstring];
        [mediaAttachments addObject:mediaAttachment];
    }];
    return mediaAttachments;
}

- (void)acceptAutoCorrectionSuggestion
{
    // This is a workaround to accept the current auto correction suggestion while not resigning as first responder. From: http://stackoverflow.com/a/27865136
    [self.textInputView.inputDelegate selectionWillChange:self.textInputView];
    [self.textInputView.inputDelegate selectionDidChange:self.textInputView];
}

#pragma mark - Send Button Enablement

- (void)configureRightAccessoryButtonState
{
    [self configureRightAccessoryButtonForText];
}

- (void)configureRightAccessoryButtonForText
{
    self.rightAccessoryButton.accessibilityLabel = ATLMessageInputToolbarSendButton;
    [self.rightAccessoryButton setImage:nil forState:UIControlStateNormal];
    self.rightAccessoryButton.contentEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    self.rightAccessoryButton.titleLabel.font = self.rightAccessoryButtonFont;
    [self.rightAccessoryButton setTitleColor:self.rightAccessoryButtonActiveColor forState:UIControlStateNormal];
    [self.rightAccessoryButton setTitleColor:self.rightAccessoryButtonDisabledColor forState:UIControlStateDisabled];
}

- (void)configureRightAccessoryButtonForImage
{
    self.rightAccessoryButton.accessibilityLabel = ATLMessageInputToolbarLocationButton;
    self.rightAccessoryButton.contentEdgeInsets = UIEdgeInsetsZero;
    [self.rightAccessoryButton setTitle:nil forState:UIControlStateNormal];
    [self.rightAccessoryButton setImage:self.rightAccessoryImage forState:UIControlStateNormal];
}


@end
