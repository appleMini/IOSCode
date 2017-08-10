//
//	CKCreator.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "CKCreator.h"

NSString *const kCKCreatorBirth = @"birth";
NSString *const kCKCreatorDescriptionField = @"description";
NSString *const kCKCreatorEmotion = @"emotion";
NSString *const kCKCreatorGender = @"gender";
NSString *const kCKCreatorGmutex = @"gmutex";
NSString *const kCKCreatorHometown = @"hometown";
NSString *const kCKCreatorIdField = @"id";
NSString *const kCKCreatorInkeVerify = @"inke_verify";
NSString *const kCKCreatorLevel = @"level";
NSString *const kCKCreatorLocation = @"location";
NSString *const kCKCreatorNick = @"nick";
NSString *const kCKCreatorPortrait = @"portrait";
NSString *const kCKCreatorProfession = @"profession";
NSString *const kCKCreatorRankVeri = @"rank_veri";
NSString *const kCKCreatorSex = @"sex";
NSString *const kCKCreatorThirdPlatform = @"third_platform";
NSString *const kCKCreatorVeriInfo = @"veri_info";
NSString *const kCKCreatorVerified = @"verified";
NSString *const kCKCreatorVerifiedReason = @"verified_reason";

@interface CKCreator ()
@end
@implementation CKCreator




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kCKCreatorBirth] isKindOfClass:[NSNull class]]){
		self.birth = dictionary[kCKCreatorBirth];
	}	
	if(![dictionary[kCKCreatorDescriptionField] isKindOfClass:[NSNull class]]){
		self.descriptionField = dictionary[kCKCreatorDescriptionField];
	}	
	if(![dictionary[kCKCreatorEmotion] isKindOfClass:[NSNull class]]){
		self.emotion = dictionary[kCKCreatorEmotion];
	}	
	if(![dictionary[kCKCreatorGender] isKindOfClass:[NSNull class]]){
		self.gender = [dictionary[kCKCreatorGender] integerValue];
	}

	if(![dictionary[kCKCreatorGmutex] isKindOfClass:[NSNull class]]){
		self.gmutex = [dictionary[kCKCreatorGmutex] integerValue];
	}

	if(![dictionary[kCKCreatorHometown] isKindOfClass:[NSNull class]]){
		self.hometown = dictionary[kCKCreatorHometown];
	}	
	if(![dictionary[kCKCreatorIdField] isKindOfClass:[NSNull class]]){
		self.idField = [dictionary[kCKCreatorIdField] integerValue];
	}

	if(![dictionary[kCKCreatorInkeVerify] isKindOfClass:[NSNull class]]){
		self.inkeVerify = [dictionary[kCKCreatorInkeVerify] integerValue];
	}

	if(![dictionary[kCKCreatorLevel] isKindOfClass:[NSNull class]]){
		self.level = [dictionary[kCKCreatorLevel] integerValue];
	}

	if(![dictionary[kCKCreatorLocation] isKindOfClass:[NSNull class]]){
		self.location = dictionary[kCKCreatorLocation];
	}	
	if(![dictionary[kCKCreatorNick] isKindOfClass:[NSNull class]]){
		self.nick = dictionary[kCKCreatorNick];
	}	
	if(![dictionary[kCKCreatorPortrait] isKindOfClass:[NSNull class]]){
		self.portrait = dictionary[kCKCreatorPortrait];
	}	
	if(![dictionary[kCKCreatorProfession] isKindOfClass:[NSNull class]]){
		self.profession = dictionary[kCKCreatorProfession];
	}	
	if(![dictionary[kCKCreatorRankVeri] isKindOfClass:[NSNull class]]){
		self.rankVeri = [dictionary[kCKCreatorRankVeri] integerValue];
	}

	if(![dictionary[kCKCreatorSex] isKindOfClass:[NSNull class]]){
		self.sex = [dictionary[kCKCreatorSex] integerValue];
	}

	if(![dictionary[kCKCreatorThirdPlatform] isKindOfClass:[NSNull class]]){
		self.thirdPlatform = dictionary[kCKCreatorThirdPlatform];
	}	
	if(![dictionary[kCKCreatorVeriInfo] isKindOfClass:[NSNull class]]){
		self.veriInfo = dictionary[kCKCreatorVeriInfo];
	}	
	if(![dictionary[kCKCreatorVerified] isKindOfClass:[NSNull class]]){
		self.verified = [dictionary[kCKCreatorVerified] integerValue];
	}

	if(![dictionary[kCKCreatorVerifiedReason] isKindOfClass:[NSNull class]]){
		self.verifiedReason = dictionary[kCKCreatorVerifiedReason];
	}	
	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	if(self.birth != nil){
		dictionary[kCKCreatorBirth] = self.birth;
	}
	if(self.descriptionField != nil){
		dictionary[kCKCreatorDescriptionField] = self.descriptionField;
	}
	if(self.emotion != nil){
		dictionary[kCKCreatorEmotion] = self.emotion;
	}
	dictionary[kCKCreatorGender] = @(self.gender);
	dictionary[kCKCreatorGmutex] = @(self.gmutex);
	if(self.hometown != nil){
		dictionary[kCKCreatorHometown] = self.hometown;
	}
	dictionary[kCKCreatorIdField] = @(self.idField);
	dictionary[kCKCreatorInkeVerify] = @(self.inkeVerify);
	dictionary[kCKCreatorLevel] = @(self.level);
	if(self.location != nil){
		dictionary[kCKCreatorLocation] = self.location;
	}
	if(self.nick != nil){
		dictionary[kCKCreatorNick] = self.nick;
	}
	if(self.portrait != nil){
		dictionary[kCKCreatorPortrait] = self.portrait;
	}
	if(self.profession != nil){
		dictionary[kCKCreatorProfession] = self.profession;
	}
	dictionary[kCKCreatorRankVeri] = @(self.rankVeri);
	dictionary[kCKCreatorSex] = @(self.sex);
	if(self.thirdPlatform != nil){
		dictionary[kCKCreatorThirdPlatform] = self.thirdPlatform;
	}
	if(self.veriInfo != nil){
		dictionary[kCKCreatorVeriInfo] = self.veriInfo;
	}
	dictionary[kCKCreatorVerified] = @(self.verified);
	if(self.verifiedReason != nil){
		dictionary[kCKCreatorVerifiedReason] = self.verifiedReason;
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
	if(self.birth != nil){
		[aCoder encodeObject:self.birth forKey:kCKCreatorBirth];
	}
	if(self.descriptionField != nil){
		[aCoder encodeObject:self.descriptionField forKey:kCKCreatorDescriptionField];
	}
	if(self.emotion != nil){
		[aCoder encodeObject:self.emotion forKey:kCKCreatorEmotion];
	}
	[aCoder encodeObject:@(self.gender) forKey:kCKCreatorGender];	[aCoder encodeObject:@(self.gmutex) forKey:kCKCreatorGmutex];	if(self.hometown != nil){
		[aCoder encodeObject:self.hometown forKey:kCKCreatorHometown];
	}
	[aCoder encodeObject:@(self.idField) forKey:kCKCreatorIdField];	[aCoder encodeObject:@(self.inkeVerify) forKey:kCKCreatorInkeVerify];	[aCoder encodeObject:@(self.level) forKey:kCKCreatorLevel];	if(self.location != nil){
		[aCoder encodeObject:self.location forKey:kCKCreatorLocation];
	}
	if(self.nick != nil){
		[aCoder encodeObject:self.nick forKey:kCKCreatorNick];
	}
	if(self.portrait != nil){
		[aCoder encodeObject:self.portrait forKey:kCKCreatorPortrait];
	}
	if(self.profession != nil){
		[aCoder encodeObject:self.profession forKey:kCKCreatorProfession];
	}
	[aCoder encodeObject:@(self.rankVeri) forKey:kCKCreatorRankVeri];	[aCoder encodeObject:@(self.sex) forKey:kCKCreatorSex];	if(self.thirdPlatform != nil){
		[aCoder encodeObject:self.thirdPlatform forKey:kCKCreatorThirdPlatform];
	}
	if(self.veriInfo != nil){
		[aCoder encodeObject:self.veriInfo forKey:kCKCreatorVeriInfo];
	}
	[aCoder encodeObject:@(self.verified) forKey:kCKCreatorVerified];	if(self.verifiedReason != nil){
		[aCoder encodeObject:self.verifiedReason forKey:kCKCreatorVerifiedReason];
	}

}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.birth = [aDecoder decodeObjectForKey:kCKCreatorBirth];
	self.descriptionField = [aDecoder decodeObjectForKey:kCKCreatorDescriptionField];
	self.emotion = [aDecoder decodeObjectForKey:kCKCreatorEmotion];
	self.gender = [[aDecoder decodeObjectForKey:kCKCreatorGender] integerValue];
	self.gmutex = [[aDecoder decodeObjectForKey:kCKCreatorGmutex] integerValue];
	self.hometown = [aDecoder decodeObjectForKey:kCKCreatorHometown];
	self.idField = [[aDecoder decodeObjectForKey:kCKCreatorIdField] integerValue];
	self.inkeVerify = [[aDecoder decodeObjectForKey:kCKCreatorInkeVerify] integerValue];
	self.level = [[aDecoder decodeObjectForKey:kCKCreatorLevel] integerValue];
	self.location = [aDecoder decodeObjectForKey:kCKCreatorLocation];
	self.nick = [aDecoder decodeObjectForKey:kCKCreatorNick];
	self.portrait = [aDecoder decodeObjectForKey:kCKCreatorPortrait];
	self.profession = [aDecoder decodeObjectForKey:kCKCreatorProfession];
	self.rankVeri = [[aDecoder decodeObjectForKey:kCKCreatorRankVeri] integerValue];
	self.sex = [[aDecoder decodeObjectForKey:kCKCreatorSex] integerValue];
	self.thirdPlatform = [aDecoder decodeObjectForKey:kCKCreatorThirdPlatform];
	self.veriInfo = [aDecoder decodeObjectForKey:kCKCreatorVeriInfo];
	self.verified = [[aDecoder decodeObjectForKey:kCKCreatorVerified] integerValue];
	self.verifiedReason = [aDecoder decodeObjectForKey:kCKCreatorVerifiedReason];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	CKCreator *copy = [CKCreator new];

	copy.birth = [self.birth copy];
	copy.descriptionField = [self.descriptionField copy];
	copy.emotion = [self.emotion copy];
	copy.gender = self.gender;
	copy.gmutex = self.gmutex;
	copy.hometown = [self.hometown copy];
	copy.idField = self.idField;
	copy.inkeVerify = self.inkeVerify;
	copy.level = self.level;
	copy.location = [self.location copy];
	copy.nick = [self.nick copy];
	copy.portrait = [self.portrait copy];
	copy.profession = [self.profession copy];
	copy.rankVeri = self.rankVeri;
	copy.sex = self.sex;
	copy.thirdPlatform = [self.thirdPlatform copy];
	copy.veriInfo = [self.veriInfo copy];
	copy.verified = self.verified;
	copy.verifiedReason = [self.verifiedReason copy];

	return copy;
}
@end