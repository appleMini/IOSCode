//
//  liverCell.m
//  Study01
//
//  Created by 小布丁 on 2017/6/16.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "LiverCell.h"
#import "UIImageView+WebCache.h"

@interface LiverCell()

@property (weak, nonatomic) IBOutlet UIImageView *portraitImgV;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;

@end

@implementation LiverCell
- (void)setLiver:(CKLive *)liver {
    if (liver) {
        [_portraitImgV sd_setImageWithURL:[NSURL URLWithString:liver.creator.portrait] placeholderImage:[UIImage imageNamed:@"loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

        }];

        _nickLabel.text = liver.creator.nick;
        _locationLabel.text = liver.creator.location;
        NSLog(@"================location===%@",liver.creator.location);
        
        NSString *msg = @"我想说说。。。。。。\n";
        NSMutableString *str = [NSMutableString stringWithString:msg];
        int count = arc4random() % 10;
        for (int i=0; i<count; i++) {
            [str appendString:msg];
        }
        
        NSLog(@"================countv===%d",count);
        _shareLabel.text = str;
        
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
