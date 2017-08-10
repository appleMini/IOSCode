//
//  InstagramFeedTableViewCell.h
//  iOS8SelfSizingCells
//
//  Created by dw_iOS on 14-10-22.
//  Copyright (c) 2014年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import <UIKit/UIKit.h>


@class InstagramItem;

@interface InstagramFeedTableViewCell : UITableViewCell

//@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
//@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

//@property (weak, nonatomic) IBOutlet UIView *leftCircleView;
//@property (weak, nonatomic) IBOutlet UIView *centerCircleView;
//@property (weak, nonatomic) IBOutlet UIView *rightCircleView;

@property (nonatomic, strong) InstagramItem *instagramItem;


@end
