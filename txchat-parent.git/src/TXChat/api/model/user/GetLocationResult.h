

#import "BaseJSONModel.h"
#import "GetLocationResult.h"
#import "ProvinceInfo.h"

@interface GetLocationResult : BaseJSONModel

@property NSArray<ProvinceInfo>* provinces;

//{"provinces": [
              //                      {
              //                          "id": 1,
              //                          "name": "北京",
              //                          "cities": [
              //                                     {
              //                                         "id": 2,
              //                                         "name": "北京",
              //                                         "districts": [
              //                                                       {
              //                                                           "id": 1,
              //                                                           "name": "西城区"
              //                                                       },


@end
