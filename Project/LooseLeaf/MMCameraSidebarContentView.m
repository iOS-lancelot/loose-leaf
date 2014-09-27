//
//  MMCameraSidebarContentView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCameraSidebarContentView.h"
#import "MMPhotoManager.h"
#import "MMImageSidebarContainerView.h"
#import "MMPermissionCameraCollectionViewCell.h"
#import "MMPermissionPhotosCollectionViewCell.h"
#import "NSThread+BlockAdditions.h"
#import "CaptureSessionManager.h"
#import "MMRotationManager.h"
#import "MMCameraCollectionViewCell.h"
#import "MMSinglePhotoCollectionViewCell.h"
#import "MMPhotoAlbumListLayout.h"
#import "UIView+Debug.h"
#import "Constants.h"

@implementation MMCameraSidebarContentView{
    MMCameraCollectionViewCell * cachedCameraCell;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // don't use the albumListScrollView at all
        [albumListScrollView removeFromSuperview];
        albumListScrollView = nil;
        
        photoListScrollView.alpha = 1;
        
        currentAlbum = [[MMPhotoManager sharedInstance] cameraRoll];
        
        [photoListScrollView registerClass:[MMCameraCollectionViewCell class] forCellWithReuseIdentifier:@"MMCameraCollectionViewCell"];
        [photoListScrollView registerClass:[MMPermissionCameraCollectionViewCell class] forCellWithReuseIdentifier:@"MMPermissionCameraCollectionViewCell"];
        [photoListScrollView registerClass:[MMPermissionPhotosCollectionViewCell class] forCellWithReuseIdentifier:@"MMPermissionPhotosCollectionViewCell"];
    }
    return self;
}

-(void) reset:(BOOL)animated{
    // noop
}

-(void) show:(BOOL)animated{
    if(isShowing){
        [photoListScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        return;
    }
    isShowing = YES;
    
    albumListScrollView.alpha = 0;
    photoListScrollView.alpha = 1;
    [[MMPhotoManager sharedInstance] initializeAlbumCache];
    
    currentAlbum = [[MMPhotoManager sharedInstance] cameraRoll];
    [self doneLoadingPhotoAlbums];
}

-(void) hide:(BOOL)animated{
    isShowing = NO;

    albumListScrollView.alpha = 0;
    photoListScrollView.alpha = 1;
    
//    [cameraRow removeFromSuperview];
//    cameraRow.delegate = nil;
//    cameraRow = nil;

    [[NSThread mainThread] performBlock:^{
        [photoListScrollView reloadData];
        if(!isShowing){
            cachedCameraCell = nil;
        }
    } afterDelay:.1];
}



#pragma mark - MMPhotoManagerDelegate

-(void) doneLoadingPhotoAlbums{
    currentAlbum = [[MMPhotoManager sharedInstance] cameraRoll];
    if(self.isShowing && photoListScrollView.alpha){
        [photoListScrollView reloadData];
    }
}

-(void) albumUpdated:(MMPhotoAlbum *)album{
    if(album == [[MMPhotoManager sharedInstance] cameraRoll]){
        currentAlbum = album;
        [self doneLoadingPhotoAlbums];
    }
}

#pragma mark - Description

-(NSString*) description{
    return @"Camera Roll";
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    // we're only working with the photoListScrollView. there's no albums here
    if(section == 0){
        return 1;
    }else{
        if([MMPhotoManager hasPhotosPermission]){
            return currentAlbum.numberOfPhotos;
        }else{
            return 1;
        }
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    // 1 section for camera row, and 1 section for camera roll photos
    return isShowing ? 2 : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if ([CaptureSessionManager hasCamera] && [CaptureSessionManager hasCameraPermission]) {
            if(cachedCameraCell){
                return cachedCameraCell;
            }else{
                cachedCameraCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MMCameraCollectionViewCell" forIndexPath:indexPath];
                cachedCameraCell.delegate = self;
                return cachedCameraCell;
            }
        }else{
            return [collectionView dequeueReusableCellWithReuseIdentifier:@"MMPermissionCameraCollectionViewCell" forIndexPath:indexPath];
        }
    }
    if([MMPhotoManager hasPhotosPermission]){
        MMSinglePhotoCollectionViewCell* photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MMSinglePhotoCollectionViewCell" forIndexPath:indexPath];
        [photoCell loadPhotoFromAlbum:currentAlbum atIndex:indexPath.row forVisibleIndex:indexPath.row];
        photoCell.delegate = self;
        return photoCell;
    }else{
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"MMPermissionPhotosCollectionViewCell" forIndexPath:indexPath];
    }
}

@end
