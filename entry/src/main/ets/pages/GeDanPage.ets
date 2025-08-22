import { songBean } from "../bean/songBean";
import { songItem } from "../item/songItem";
import { AVPlayerUtils } from "../utils/AVPlayerUtils";
import { CustomTransitionUtils } from "../utils/CustomTransitionUtils";
import { getInternetImgColor } from "../utils/ImageUtils";
import { SharePreferenceUtil } from "../utils/SharePreferenceUtil";
import { promptAction } from "@kit.ArkUI";
import hilog from "@ohos.hilog";
import { DebounceSingletonUtil } from "../utils/DebounceSingletonUtil";
import { CommonUtils } from "../utils/CommonUtils";
import { SongUtils } from "../utils/SongUtils";
import { EventContanst } from "../utils/EventContanst";

@Component
export struct GeDanPage {
  @State pageInfo: NavPathStack = new NavPathStack()
  @State pageId: string = ''
  @State translateY: string = ''
  @StorageLink('geDan') geDanSongArray: songBean[] = []
  @StorageLink('isPlaying') isPlaying: boolean = false
  @StorageLink('nowSong') nowSong: songBean = new songBean()
  @StorageLink('likeList') likeList: songBean[] = []
  @StorageLink('nearList') nearList: songBean[] = []

  registerCallback() {
    CustomTransitionUtils.getInstance().registerNavParam(this.pageId,
      // 设置转场动画起点，根据不同的转场类型分别设置
      (isPush: boolean, isExit: boolean) => {
        if (isPush) {
          if (isExit) {
            this.translateY = '0';
          } else {
            this.translateY = '100%';
          }
        } else {
          if (isExit) {
            this.translateY = '0';
          } else {
            this.translateY = '0';
          }
        }
      },
      // 设置转场动画终点，根据不同的转场类型分别设置
      (isPush: boolean, isExit: boolean) => {
        if (isPush) {
          if (isExit) {
            this.translateY = '0';
          } else {
            this.translateY = '0';
          }
        } else {
          if (isExit) {
            this.translateY = '100%';
          } else {
            this.translateY = '0';
          }
        }
      });
  }

  aboutToAppear(): void {
    if (this.geDanSongArray.length === 0 && this.nowSong) {
      this.geDanSongArray.push(this.nowSong)
    }
  }

  build() {


    NavDestination() {
      Column() {
        Blank().width('100%')
          .height('40%').onClick(() => {
          this.pageInfo.pop(this.pageId)
        })
        Column() {
          if (this.geDanSongArray.length != 0) {
            List({ space: 10 }) {
              ForEach(this.geDanSongArray, (data: songBean, index: number) => {
                ListItem() {
                  this.geDanSongItem(data, index)
                }.width('100%')
                .height('30vp')
                .onClick(() => {
                  if (DebounceSingletonUtil.getInstance().isDebounced('防抖', 500)) {
                    CommonUtils.toastShow('点击太快了哦～')
                  }else {
                    getInternetImgColor(data.pic).then((color) => {
                      hilog.debug(1,'wyp','歌单换歌')
                      data.backgroundColor = color
                      AppStorage.setOrCreate('nowSong', data)
                      SongUtils.zuiJin(data,this.nearList)
                      SharePreferenceUtil.getInstance().putString('lastSong', JSON.stringify(data))
                      CommonUtils.postEvent(EventContanst.songWords,'','next')
                      AVPlayerUtils.getInstance().play(data.url)
                    })
                  }


                })
              })
            }.margin({ bottom: 10, top: 10, left: 10 })
            .scrollBar(BarState.Off)
          } else {
            Row() {
              Text('暂无歌单信息')
                .fontWeight(FontWeight.Bold)

            }.width('100%')
            .height('100%')
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
          }


        }
        .height('60%')
        .width('100%')
        .borderRadius({ topLeft: 20, topRight: 20 })
        .backgroundColor(Color.White)
      }.width('100%')
      .height('100%')
      .backgroundColor(Color.Transparent)

    }
    .backgroundColor(Color.Transparent)
    .onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack;
      if (context.navDestinationId) {
        this.pageId = context.navDestinationId;
        // 页面创建时注册自定义转场动画参数
        this.registerCallback();
      }
    })
    .hideTitleBar(true)
    .translate({ y: this.translateY })
    .onDisAppear(() => {
      // 页面销毁时解注册自定义转场动画参数
      CustomTransitionUtils.getInstance().unRegisterNavParam(this.pageId);
    })
    .mode(NavDestinationMode.DIALOG)

  }

  @Builder
  geDanSongItem(song: songBean, index: number) {
    Row() {

      Text() {
        Span(song.name).fontColor((this.nowSong.url === song.url) ? '#64C37D' : Color.Black)
        Span(`-${song.artist}`).fontSize(13).fontColor(Color.Gray)
      }
      .width(0)
      .layoutWeight(1)
      .height('100%')
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)


      Row() {
        Image($rawfile(this.isPlaying ? 'playing_green.gif' : 'pause_green.png'))
          .width(23)
          .height(23)
          .objectFit(ImageFit.Fill)
          .margin({ left: 20 })
          .visibility(this.nowSong.url === song.url ? Visibility.Visible : Visibility.Hidden)
          .draggable(false)

        Image($rawfile((this.likeList.some(data => data.id === song.id) && this.likeList) ? 'like.png' :
          'unlike.png'))
          .width(15)
          .height(15)
          .objectFit(ImageFit.Fill)
          .margin({ left: 20 })
          .draggable(false)
          .onClick(()=>{
            SongUtils.likeSong(song,this.likeList)
          })

        Image($rawfile('chacha.png'))
          .width(15)
          .height(15)
          .objectFit(ImageFit.Fill)
          .draggable(false)
          .margin({ left: 20 })
          .onClick(() => {
            if (this.geDanSongArray.length === 1){
              promptAction.showToast({
                message: '只剩最后一首歌了哦～',
                duration: 500,//时长
                bottom: 300   //距离底部
              })
              return
            }

            this.geDanSongArray.splice(index, 1)

            if (this.nowSong.name === song.name) {
              getInternetImgColor(song.pic).then((color) => {
                this.nowSong.backgroundColor = color
              })
              if (index === this.geDanSongArray.length) {
                this.nowSong = this.geDanSongArray[0]
                AVPlayerUtils.getInstance().play(this.geDanSongArray[0].url)
              } else {
                this.nowSong = this.geDanSongArray[index]
                AVPlayerUtils.getInstance().play(this.geDanSongArray[index].url)
              }
              CommonUtils.postEvent(EventContanst.songWords,'','next')
            }
          })


      }.height('100%')
      .margin({ right: 10 })

    }.height('100%')
    .width('100%')
  }
}


@Builder
export function GeDanPageBuilder(name: string, param: object) {
  GeDanPage()
}


