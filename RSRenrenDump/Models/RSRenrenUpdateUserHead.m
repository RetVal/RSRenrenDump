//
//  RSRenrenUpdateUserHead.m
//  RSRenren
//
//  Created by RetVal on 10/11/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSRenrenUpdateUserHead.h"

@implementation RSRenrenUpdateUserHead
//Request URL:http://head2.upload.renren.com/upload.fcgi
//Request Method:POST
//Status Code:200 OK
//Request Headersview source
//Accept:*/*
//         Accept-Encoding:gzip,deflate,sdch
//         Accept-Language:en-US,en;q=0.8
//         Connection:keep-alive
//         Content-Length:80
//         Content-Type:application/x-www-form-urlencoded
//         Cookie:anonymid=hj14h3vj-fi3sbx; _r01_=1; _de=C070DFE6D36B67DC3399691954C56086696BF75400CE19CC; mtOnce=1; mt=eHEIGyrsM_p6aOOblqBO9p; cp_config=2; XNESSESSIONID=5efb6edcd4fd; p=5201612d90b39131b64bd2f54e4508493; ap=340278563; t=17deaa86c175be50fb9832288fcfdf863; societyguester=17deaa86c175be50fb9832288fcfdf863; id=340278563; xnsid=5922d386; WebOnLineNotice_340278563=1; at=1; loginfrom=null
//         Host:head2.upload.renren.com
//         Origin:http://head2.upload.renren.com
//         Referer:http://head2.upload.renren.com/ajaxproxy.htm
//         User-Agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.69 Safari/537.36
//         X-Requested-With:XMLHttpRequest
//         Form Dataview sourceview URL encoded
//         pagetype:addthumbnail
//         uploadid:340278563
//         hostid:340278563
//         x:5
//         y:0
//         user:340278563
//         Response Headersview source
//         Connection:keep-alive
//         Content-Encoding:gzip
//         Content-Type:text/html; charset=utf-8
//         Date:Fri, 11 Oct 2013 09:36:29 GMT
//         Server:nginx/1.2.0
//         Transfer-Encoding:chunked
//
//  http://head.upload.renren.com/profile/AjaxCertificate.do
//  json result isntance : {"hostid":340278563,"tsc":"0162c66c27f6a30a5abe7a3a92e29508"}
//
//  http://head2.upload.renren.com/head2/Photo2Head.do
//  post
//  data:
//      url: image url
//      hostid: user host id
//      tsc:0162c66c27f6a30a5abe7a3a92e29508
//
//  http://head2.upload.renren.com/head2/Photo2Head.do?url=http%3A%2F%2Fhdn.xnimg.cn%2Fphotos%2Fhdn121%2F20130629%2F1905%2Fh_large_t4cZ_26be0000015d111a.jpg&hostid=340278563&tsc=0162c66c27f6a30a5abe7a3a92e29508&requestToken=-754890765&_rtk=9ec2464d
//
//
//<div id="single-column" class="photo-upload-page">
//<form target="uploadPlainIframe" id="uploadForm" class="form-photoupload" method="post" action="http://upload.renren.com/upload.fcgi?pagetype=addphotoplain&hostid=340278563&uploadid=8888" enctype="multipart/form-data">
//    upload.renren.com/upload.fcgi?pagetype=addphotoplain&hostid=340278563&uploadid=8888
//
//  上傳照片
/*
    http://upload.renren.com/upload/340278563/photo/save
 
    Host: upload.renren.com
    Connection: keep-alive
    Referer: http://upload.renren.com/addphotoPlain.do
    Origin: http://upload.renren.com
    Cache-Control: no-cache
post
    flag:0/
    album.id:906004381
    album.description:""
    privacyParams:{"sourceControl":99}
    
 
 switch (privacyData.albumSourceControl) {
 case '99':
 privacyData.albumGroupName = '公开';
 privacyData.albumGroupType = 'public';
 break;
 case '4':
 privacyData.albumGroupName = '使用密码保护';
 privacyData.albumGroupType = 'password';
 break;
 case '0':
 privacyData.albumGroupName = '好友可见';
 privacyData.albumGroupType = 'friend';
 break;
 case '-1':
 privacyData.albumGroupName = '仅自己可见';
 privacyData.albumGroupType = 'private';
 break;
 */

/*
    photos:
 %5B%7B%22code%22%3A0%2C%22msg%22%3A%22%22%2C%22filename%22%3A%2235a5ab5906177b4e79f731c7a09a976e.jpg%22%2C%22filesize%22%3A260889%2C%22width%22%3A960%2C%22height%22%3A700%2C%22images%22%3A%5B%7B%22url%22%3A%22fmn056%2F20131011%2F1910%2Flarge_KKTI_383100000419118c.jpg%22%2C%22type%22%3A%22large%22%2C%22width%22%3A720%2C%22height%22%3A525%7D%2C%7B%22url%22%3A%22fmn056%2F20131011%2F1910%2Fmain_KKTI_383100000419118c.jpg%22%2C%22type%22%3A%22main%22%2C%22width%22%3A200%2C%22height%22%3A145%7D%2C%7B%22url%22%3A%22fmn056%2F20131011%2F1910%2Ftiny_KKTI_383100000419118c.jpg%22%2C%22type%22%3A%22tiny%22%2C%22width%22%3A50%2C%22height%22%3A50%7D%2C%7B%22url%22%3A%22fmn056%2F20131011%2F1910%2Fhead_KKTI_383100000419118c.jpg%22%2C%22type%22%3A%22head%22%2C%22width%22%3A100%2C%22height%22%3A72%7D%2C%7B%22url%22%3A%22fmn056%2F20131011%2F1910%2Foriginal_KKTI_383100000419118c.jpg%22%2C%22type%22%3A%22xlarge%22%2C%22width%22%3A960%2C%22height%22%3A700%7D%5D%7D%5D
    %5B%7B%22code%22%3A0%2C%22msg%22%3A%22%22%2C%22filename%22%3A%2235a5ab5906177b4e79f731c7a09a976e.jpg%22%2C%22filesize%22%3A260889%2C%22width%22%3A960%2C%22height%22%3A700%2C%22images%22%3A%5B%7B%22url%22%3A%22fmn058%2F20131011%2F1940%2Flarge_saED_7d3e000005e71260.jpg%22%2C%22type%22%3A%22large%22%2C%22width%22%3A720%2C%22height%22%3A525%7D%2C%7B%22url%22%3A%22fmn058%2F20131011%2F1940%2Fmain_saED_7d3e000005e71260.jpg%22%2C%22type%22%3A%22main%22%2C%22width%22%3A200%2C%22height%22%3A145%7D%2C%7B%22url%22%3A%22fmn058%2F20131011%2F1940%2Ftiny_saED_7d3e000005e71260.jpg%22%2C%22type%22%3A%22tiny%22%2C%22width%22%3A50%2C%22height%22%3A50%7D%2C%7B%22url%22%3A%22fmn058%2F20131011%2F1940%2Fhead_saED_7d3e000005e71260.jpg%22%2C%22type%22%3A%22head%22%2C%22width%22%3A100%2C%22height%22%3A72%7D%2C%7B%22url%22%3A%22fmn058%2F20131011%2F1940%2Foriginal_saED_7d3e000005e71260.jpg%22%2C%22type%22%3A%22xlarge%22%2C%22width%22%3A960%2C%22height%22%3A700%7D%5D%7D%5D
    [
        {
            "code":0,
            "msg":"",
            "filename":"35a5ab5906177b4e79f731c7a09a976e.jpg",
            "filesize":260889,
            "width":960,
            "height":700,
            "images":
            [
                {
                    "url":"fmn056/20131011/1910/large_KKTI_383100000419118c.jpg",
                    "type":"large",
                    "width":720,
                    "height":525
                },
                {
                    "url":"fmn056/20131011/1910/main_KKTI_383100000419118c.jpg",
                    "type":"main",
                    "width":200,
                    "height":145
                },
                {
                    "url":"fmn056/20131011/1910/tiny_KKTI_383100000419118c.jpg",
                    "type":"tiny",
                    "width":50,
                    "height":50
                },
                {
                    "url":"fmn056/20131011/1910/head_KKTI_383100000419118c.jpg",
                    "type":"head",
                    "width":100,
                    "height":72
                },
                {
                    "url":"fmn056/20131011/1910/original_KKTI_383100000419118c.jpg",
                    "type":"xlarge",
                    "width":960,
                    "height":700
                }
            ]
        }
    ]
 
    [{"code":0,"msg":"","filename":"35a5ab5906177b4e79f731c7a09a976e.jpg","filesize":260889,"width":960,"height":700,"images":[{"url":"fmn058/20131011/1940/large_saED_7d3e000005e71260.jpg","type":"large","width":720,"height":525},{"url":"fmn058/20131011/1940/main_saED_7d3e000005e71260.jpg","type":"main","width":200,"height":145},{"url":"fmn058/20131011/1940/tiny_saED_7d3e000005e71260.jpg","type":"tiny","width":50,"height":50},{"url":"fmn058/20131011/1940/head_saED_7d3e000005e71260.jpg","type":"head","width":100,"height":72},{"url":"fmn058/20131011/1940/original_saED_7d3e000005e71260.jpg","type":"xlarge","width":960,"height":700}]}]
 */
@end
