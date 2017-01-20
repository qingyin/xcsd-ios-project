

#import "BaseResponse.h"

#import "CommenListResult.h"

@interface CommentListResponse : BaseResponse

@property CommenListResult *result;
//{
//    errorCode = 0;
//    message = Success;
//    result =     {
//        pageSize = 20;
//        rows =         (
//                        {
//                            applyTo = "<null>";
//                            content = "\U597d\U56de\U5bb6\U770b\U770b";
//                            createDate = 1415677177000;
//                            deletable = 1;
//                            id = 133;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = high;
//                            createDate = 1415673684000;
//                            deletable = 1;
//                            id = 116;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = munch;
//                            createDate = 1415673612000;
//                            deletable = 1;
//                            id = 113;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = fjkhg;
//                            createDate = 1415673397000;
//                            deletable = 1;
//                            id = 108;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = fjkhgg;
//                            createDate = 1415673389000;
//                            deletable = 1;
//                            id = 107;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = fjkhgg;
//                            createDate = 1415673384000;
//                            deletable = 1;
//                            id = 106;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = "\U54af\U4e0b\U96e8\U54af";
//                            createDate = 1415243115000;
//                            deletable = 1;
//                            id = 74;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = "\U4f60\U770b\U770b\U54af\U54e6";
//                            createDate = 1415243108000;
//                            deletable = 1;
//                            id = 73;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = "\U6765\U54af\U54e6\U770b\U770b\U54af\U5594\U5594\U5594";
//                            createDate = 1415243096000;
//                            deletable = 1;
//                            id = 72;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = "\U5475\U5475\U5475\U5475\U5475\U5475";
//                            createDate = 1415160363000;
//                            deletable = 1;
//                            id = 51;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = "\U5fae\U4fe1yww";
//                            createDate = 1415160353000;
//                            deletable = 1;
//                            id = 50;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = "\U7a81\U7a81\U7a81";
//                            createDate = 1415160340000;
//                            deletable = 1;
//                            id = 49;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = "\U54c8\U54c8\U54c8";
//                            createDate = 1415160328000;
//                            deletable = 1;
//                            id = 48;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = "qq wet";
//                            createDate = 1415159902000;
//                            deletable = 1;
//                            id = 47;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = asdf;
//                            createDate = 1415159892000;
//                            deletable = 1;
//                            id = 46;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = jjj;
//                            createDate = 1415159884000;
//                            deletable = 1;
//                            id = 45;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = mmmmm;
//                            createDate = 1415158886000;
//                            deletable = 1;
//                            id = 44;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = jjj;
//                            createDate = 1415158881000;
//                            deletable = 1;
//                            id = 43;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = gggg;
//                            createDate = 1415158878000;
//                            deletable = 1;
//                            id = 42;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        },
//                        {
//                            applyTo = "<null>";
//                            content = gggg;
//                            createDate = 1415158875000;
//                            deletable = 1;
//                            id = 41;
//                            user =                 {
//                                id = 132;
//                                name = test;
//                            };
//                        }
//                        );
//        total = 24;
//    };
//}

//{
//    errorCode = 0;
//    message = Success;
//    result =     (
//                  {
//                      applyTo = "<null>";
//                      content = "   \U6d4b\U8bd5   ";
//                      createDate = "<null>";
//                      deletable = 1;
//                      id = 32;
//                      user =             {
//                          id = 132;
//                          name = test;
//                      };
//                  },
//                  {
//                      applyTo = "<null>";
//                      content = test;
//                      createDate = "<null>";
//                      deletable = 1;
//                      id = 31;
//                      user =             {
//                          id = 132;
//                          name = test;
//                      };
//                  }
//                  );
//}

@end
