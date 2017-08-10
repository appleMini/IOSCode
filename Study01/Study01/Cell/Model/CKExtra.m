//
//	CKExtra.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "CKExtra.h"

NSString *const kCKExtraCover = @"cover";
NSString *const kCKExtraLabel = @"label";

@interface CKExtra ()
@end
@implementation CKExtra




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kCKExtraCover] isKindOfClass:[NSNull class]]){
		self.cover = dictionary[kCKExtraCover];
	}	
	if(![dictionary[kCKExtraLabel] isKindOfClass:[NSNull class]]){
		self.label = dictionary[kCKExtraLabel];
	}	
	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	if(self.cover != nil){
		dictionary[kCKExtraCover] = self.cover;
	}
	if(self.label != nil){
		dictionary[kCKExtraLabel] = self.label;
	}
	return dictionary;

}

/**
 * Implementation of NSCoding encoding method
 */
/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if(self.cover != nil){
		[aCoder encodeObject:self.cover forKey:kCKExtraCover];
	}
	if(self.label != nil){
		[aCoder encodeObject:self.label forKey:kCKExtraLabel];
	}

}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.cover = [aDecoder decodeObjectForKey:kCKExtraCover];
	self.label = [aDecoder decodeObjectForKey:kCKExtraLabel];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	CKExtra *copy = [CKExtra new];

	copy.cover = [self.cover copy];
	copy.label = [self.label copy];

	return copy;
}
@end