//
//  DetailController.h
//  RssReader
//

#import <UIKit/UIKit.h>

@class Currency;
@interface DetailController : UIViewController {
	
	Currency *item;
	IBOutlet UILabel *itemTitle;
  	IBOutlet UILabel *itemDate;
}

@property (retain, nonatomic) Currency *item;
@property (retain, nonatomic) IBOutlet UILabel *itemTitle;
@property (retain, nonatomic) IBOutlet UILabel *itemDate;

- (id)initWithCurrency:(Currency *)theCurrencyItem;


@end
