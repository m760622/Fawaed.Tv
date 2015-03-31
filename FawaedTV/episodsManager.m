//
//  episodsManager.m
//  FawaedTV
//
//  Created by Homam on 2015-03-30.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "episodsManager.h"
#import "bookmarkObj.h"
#import "fileObject.h"
#import "FCFileManager.h"

@implementation episodsManager
+(void)episodeDownloaded:(episodeObject *)epObj type:(episodeDownloadedFileType)epType{

    episodsManager *epMan = [episodsManager new];
    
    /// record the local file name in the local db
    [epMan registerFileForEpisode:epObj type:epType];
    /// add bookmark for this episode
    [epMan addBookmarkForEpisode:epObj];
    
}
+(void)episodeDeleted:(episodeObject *)epObj type:(episodeDownloadedFileType)epType{
   
    episodsManager *epMan = [episodsManager new];
    /// remove bookmark for this episode
    [epMan removeBookmarkForEpisode:epObj];
    /// remove the record in the local file name in the local db
    [epMan removeFileForEpisode:epObj type:epType];
}


-(void)addBookmarkForEpisode:(episodeObject *)epObj{
    bookmarkObj *bObj       = [bookmarkObj new];
    bObj.bookmarkContentID  = epObj.episodeID;
    bObj.bookmarkTitle      = epObj.episodeTitle;
    bObj.bookmarkImageLink  = epObj.episodeLinkImage;
    bObj.bookmarkType       = bookmarkTypeEpisode;
    /// 0. check if this has been already bookmarked
    bookmarkObj *obj =[bObj isAlreadyAvailableInDBWithCompletion:Nil];
    if (!obj) {
        //// 1. it's not in the db so add it
        [bObj addToDataBaseWithCompletion:^(bookmarkObj *newObj) {
            /// send notification to the episode controller that is resbonsible for this
        }];
    }


}
-(void)removeBookmarkForEpisode:(episodeObject *)epObj{
    bookmarkObj *bObject        = [bookmarkObj new];
    bObject.bookmarkContentID  = epObj.episodeID;
    bObject.bookmarkTitle      = epObj.episodeTitle;
    bObject.bookmarkImageLink  = epObj.episodeLinkImage;
    bObject.bookmarkType       = bookmarkTypeEpisode;
    /// 0. check if this has been already bookmarked
    bookmarkObj *obj = [bObject isAlreadyAvailableInDBWithCompletion:Nil];
    if (obj) {
        /// this bookmark exsits in the db
        /// 1. it's in the db so remove it
        [obj removeFromDataBase];
    }
}
-(void)removeFileForEpisode:(episodeObject *)epObj type:(episodeDownloadedFileType)epType{
    NSString *fileName, *fileSize;
    if (epType == episodeDownloadedFileAudio) {
        fileName = [NSString stringWithFormat:@"%d.mp3",epObj.episodeID];
        fileSize = [FCFileManager sizeInMBForFileAtPath:epObj.episodeLinkMp3Local];
    }else{
        fileName = [NSString stringWithFormat:@"%d.avi",epObj.episodeID];
        fileSize = [FCFileManager sizeInMBForFileAtPath:epObj.episodeLinkAviLocal];
    }
    
    fileObject *fObj        = [fileObject new];
    fObj.fileName           = fileName;
    fObj.fileEpisodeTitle   = epObj.episodeTitle;
    fObj.fileEpisodeLecturer= epObj.episodeLecturer;
    fObj.fileSize           = fileSize;
    
    [fObj removeFromDataBase];
    
    [FCFileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",[FCFileManager pathForDocumentsDirectory],fileName]];
}
-(void)registerFileForEpisode:(episodeObject *)epObj type:(episodeDownloadedFileType)epType{
    NSString *fileName, *fileSize;
    if (epType == episodeDownloadedFileAudio) {
        fileName = [NSString stringWithFormat:@"%d.mp3",epObj.episodeID];
        fileSize = [FCFileManager sizeInMBForFileAtPath:epObj.episodeLinkMp3Local];
    }else{
        fileName = [NSString stringWithFormat:@"%d.avi",epObj.episodeID];
        fileSize = [FCFileManager sizeInMBForFileAtPath:epObj.episodeLinkAviLocal];
    }
    
    fileObject *fObj        = [fileObject new];
    fObj.fileName           = fileName;
    fObj.fileSize           = fileSize;
    fObj.fileEpisodeID      = epObj.episodeID;
    fObj.fileEpisodeTitle   = epObj.episodeTitle;
    fObj.fileEpisodeLecturer= epObj.episodeLecturer;
    
    if (![fObj isAlreadyAvailableInDB]) {
        [fObj addToDataBase];
    }
}
@end