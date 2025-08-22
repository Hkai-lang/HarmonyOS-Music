import { curves } from "@kit.ArkUI";
import { songBean } from "../bean/songBean";
import { songItem } from "../item/songItem";
import { AVPlayerUtils } from "../utils/AVPlayerUtils";
import { CommonUtils } from "../utils/CommonUtils";
import { EventContanst } from "../utils/EventContanst";
import { getColor, getInternetImgColor } from "../utils/ImageUtils";
import { SharePreferenceUtil } from "../utils/SharePreferenceUtil";
import { SongUtils } from "../utils/SongUtils";

@Component
export struct songListPage2 {
  @State pageInfo: NavPathStack = new NavPathStack()
  @State offsetY: number = 0
  @State offsetY1: number = 0
  @State offsetY2: number = 0
  @State private downOpacityValue: number = 0;
  @State songList: songBean[] = []
  @StorageLink('likeList') likeList: songBean[] = []
  @StorageLink('nearList') nearList: songBean[] = []

  aboutToAppear(): void {

  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Stack({ alignContent: Alignment.Top }) {

            Image(this.songList[2].pic)
              .width(200)
              .height(200)
              .borderRadius(10)
              .rotate({ angle: 6 })
              .margin({ left: 130 })
              .translate({ y: this.offsetY })
              .opacity(this.downOpacityValue)
              .onAppear(() => {
                this.getUIContext().animateTo({
                  duration: 2000,
                  curve: curves.springMotion(0.5, 0.3),
                  delay: 500
                }, () => {
                  this.offsetY = 30
                  this.downOpacityValue = 1
                })
              })


            Image(this.songList[1].pic)
              .width(200)
              .height(200)
              .borderRadius(10)
              .rotate({ angle: -20 })
              .margin({ top: 90, right: 130 })
              .translate({ y: this.offsetY1 })
              .opacity(this.downOpacityValue)
              .onAppear(() => {
                this.getUIContext().animateTo({
                  duration: 2000,
                  curve: curves.springMotion(0.5, 0.5),
                  delay: 600
                }, () => {
                  this.offsetY1 = 30
                  this.downOpacityValue = 1
                })
              })


            Image(this.songList[0].pic)
              .width(200)
              .height(200)
              .borderRadius(10)
              .rotate({ angle: 20 })
              .margin({ top: 180, left: 130 })
              .translate({ y: this.offsetY2 })
              .opacity(this.downOpacityValue)
              .onAppear(() => {
                this.getUIContext().animateTo({
                  duration: 2000,
                  curve: curves.springMotion(0.5, 0.5),
                  delay: 700
                }, () => {
                  this.offsetY2 = 30
                  this.downOpacityValue = 1
                })
              })

            Text('推荐歌单')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .margin({ top: 430 })

            Row() {
              Image($rawfile('back_white.png'))
                .width(30)
                .height(30)
                .margin({ left: 15 })
                .draggable(false)
                .onClick(() => {
                  this.pageInfo.pop()
                  AppStorage.setOrCreate('isSongList', false)
                })
            }.width('100%')
            .margin({ top: 50 })

          }.width('100%')

          Row() {
            Row() {
              Image($rawfile('bofang.png'))
                .width(18)
                .height(18)
                .onClick(() => {
                  AppStorage.setOrCreate('nowSong', this.songList[0])
                  AppStorage.setOrCreate('isExpanded', true)
                  AppStorage.setOrCreate('geDan', this.songList)
                  CommonUtils.postEvent(EventContanst.songWords, '', 'next')
                  SharePreferenceUtil.getInstance().putString('lastSong', JSON.stringify(this.songList[0]))
                  setTimeout(() => {
                    AppStorage.setOrCreate('isExpanded', false)
                  }, 5000)

                  AVPlayerUtils.getInstance().play(this.songList[0].url)
                })
            }
            .width(55)
            .height(40)
            .borderRadius(20)
            .backgroundColor('#F13131')
            .justifyContent(FlexAlign.Center)


            Text(`全部播放 ${this.songList.length}`)
              .margin({ left: 10 })
              .fontColor(Color.White)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)

          }
          .width('100%')
          .margin({ left: 15 })

          Column({ space: 10 }) {
            ForEach(this.songList, (item: songBean, index ?: number) => {
              this.songItem(item)

            })
          }.width('95%')
          .margin({ top: 15, bottom: 75 })

        }.width('100%')

      }.width('100%')
      .backgroundColor(this.songList[0].backgroundColor)
      .scrollBar(BarState.Off)
    }.onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack
      let param: object = new Object()
      param = this.pageInfo.getParamByName('songListPage2')[0] as object
      this.songList = param['list']
    })
    .hideTitleBar(true)

  }

  @Builder
  songItem(songInfo: songBean) {
    Row() {
      Image(songInfo.pic)
        .width(55)
        .height(55)
        .borderRadius(4)

      Column({ space: 5 }) {
        Text(songInfo.name)
          .fontSize(16)
          .width(275)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F5F1FA')
          .maxLines(1)
          .textOverflow({overflow: TextOverflow.Ellipsis })

        Row({ space: 5 }) {
          Row() {
            Text('超清母带').fontSize(10).fontColor('#C9963D')
          }
          .border({ color: '#C9963D', radius: 2, width: 1 })


          Text(songInfo.artist)
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#858189')
        }

      }.margin({ left: 8 })
      .alignItems(HorizontalAlign.Start)
      .width(0)
      .layoutWeight(1)

      Image($rawfile((this.likeList.some(song => song.id === songInfo.id) && this.likeList) ? 'like.png' :
        'unlike.png'))
        .width(20)
        .height(20)
        .alignSelf(ItemAlign.Center)
        .draggable(false)
        .onClick(() => {
          SongUtils.likeSong(songInfo, this.likeList)
        })

    }.width('100%')
    .onClick(()=>{
      getInternetImgColor(songInfo.pic).then((color) => {

        songInfo.backgroundColor = color
        AppStorage.setOrCreate('nowSong', songInfo)
        SongUtils.zuiJin(songInfo,this.nearList)
        AppStorage.setOrCreate('isExpanded', true)
        AppStorage.setOrCreate('geDan', this.songList)
        CommonUtils.postEvent(EventContanst.songWords, '', 'next')
        SharePreferenceUtil.getInstance().putString('lastSong', JSON.stringify(songInfo))
        setTimeout(() => {
          AppStorage.setOrCreate('isExpanded', false)
        }, 5000)

        AVPlayerUtils.getInstance().play(songInfo.url)

      })
    })
  }
}

@Builder
export function songListPage2Builder(name: string, param: object) {
  songListPage2()
}

