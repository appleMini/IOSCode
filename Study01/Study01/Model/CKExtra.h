#import <UIKit/UIKit.h>

@interface CKExtra : NSObject

@property (nonatomic, strong) NSObject * cover;
@property (nonatomic, strong) NSArray * label;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end