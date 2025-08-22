import { CommonUtils } from "../utils/CommonUtils"
import { LengthMetricsUnit } from "@kit.ArkUI"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { songBean } from "../bean/songBean"
import { songItem } from "../item/songItem"
import { songListItem } from "./songListItem"
import { getInternetImgColor } from "../utils/ImageUtils"
import { EventContanst } from "../utils/EventContanst"
import { SharePreferenceUtil } from "../utils/SharePreferenceUtil"
import { AVPlayerUtils } from "../utils/AVPlayerUtils"
import { SongUtils } from "../utils/SongUtils"


@Component
export struct songListPage {
  pageInfo: NavPathStack = new NavPathStack()
  @State name: string = ''
  @State songList: songBean[] = []
  @State img: string = ''
  @State content: string = ''
  @State auth: string = ''
  @StorageLink('nowSong') nowSong: songBean = new songBean()
  @StorageLink('nearList') nearList: songBean[] = []

  aboutToAppear(): void {
    // CommonUtils.setStatusBarColor('#F0F5F6',getContext(this))

  }

  build() {

    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Scroll() {
          Column() {
            Stack({ alignContent: Alignment.TopStart }) {
              Image($rawfile(this.img))
                .height('100%')
                .width('100%')
                .objectFit(ImageFit.Cover)

              Column()
                .width('100%')
                .height('100%')
                .backgroundColor(Color.Transparent)
                .linearGradient({
                  colors: [['rgba(0,0,0,0)', 0.1], ['rgba(0,0,0,0)', 0.2], [0xF0F4F6, 1.0]],
                  direction: GradientDirection.Bottom
                })

              Column() {


                Text(this.name)
                  .fontColor(Color.Black)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 260, left: 18 })
                  .alignSelf(ItemAlign.Start)


                Column() {
                  Text('今日热门评论').margin({ top: 25, left: 10 }).fontWeight(FontWeight.Bold)
                  Text(this.content)
                    .textIndent(35)
                    .margin({ top: 10, left: 10 })
                    .fontWeight(FontWeight.Bold)
                    .letterSpacing(4)

                  Text(this.auth)
                    .margin({ top: 10 })
                    .width('95%')
                    .fontSize(14)
                    .textAlign(TextAlign.End)

                }
                .backgroundColor(Color.White)
                .borderRadius(5)
                .margin({ top: 10 })
                .width('90%')
                .height(140)
                .alignItems(HorizontalAlign.Start)

              }
              .margin({ top: 50 })
              .width('100%')
              .height('100%')

            }.width('100%')
            .height(520)

            Row() {

              Row() {
                Image($rawfile('bofang.png')).width(18).height(18)
                  .onClick(() => {
                    getInternetImgColor(this.songList[0].pic).then((color) => {

                      this.songList[0].backgroundColor = color
                      AppStorage.setOrCreate('nowSong', this.songList[0])
                      SongUtils.zuiJin(this.songList[0],this.nearList)
                      AppStorage.setOrCreate('isExpanded', true)
                      AppStorage.setOrCreate('geDan', this.songList)
                      CommonUtils.postEvent(EventContanst.songWords, '', 'next')
                      SharePreferenceUtil.getInstance().putString('lastSong', JSON.stringify(this.songList[0]))
                      setTimeout(() => {
                        AppStorage.setOrCreate('isExpanded', false)
                      }, 5000)

                      AVPlayerUtils.getInstance().play(this.songList[0].url)

                    })
                  })
              }
              .width(55)
              .height(40)
              .borderRadius(20)
              .backgroundColor('#F13131')
              .justifyContent(FlexAlign.Center)

              Text(`全部播放 ${this.songList.length}`)
                .margin({ left: 10 })

            }.justifyContent(FlexAlign.Start)
            .width('90%')
            .alignItems(VerticalAlign.Center)

            Column() {
              ForEach(this.songList, (item: songBean, index: number) => {
                songListItem({
                  songInfo: item,
                  index: index
                }).onClick(() => {
                  getInternetImgColor(item.pic).then((color) => {

                    item.backgroundColor = color
                    AppStorage.setOrCreate('nowSong', item)
                    SongUtils.zuiJin(item,this.nearList)
                    AppStorage.setOrCreate('isExpanded', true)
                    AppStorage.setOrCreate('geDan', this.songList)
                    CommonUtils.postEvent(EventContanst.songWords, '', 'next')
                    SharePreferenceUtil.getInstance().putString('lastSong', JSON.stringify(item))
                    setTimeout(() => {
                      AppStorage.setOrCreate('isExpanded', false)
                    }, 5000)

                    AVPlayerUtils.getInstance().play(item.url)

                  })
                })

              })
            }.width('100%')
            .margin({ bottom: 70 })

          }.width('100%')

        }
        .width('100%')
        .scrollBar(BarState.Off)
        .backgroundColor('#F0F4F6')

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
      }
      .width('100%')

    }.hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack;
      let param: object = new Object()
      param = this.pageInfo.getParamByName('songListPage')[0] as object
      this.name = param['name']
      this.songList = param['list']
      this.img = param['img']
      this.content = param['text']
      this.auth = param['auth']

    })

  }
}

@Builder
export function songListBuilder(name: string, param: object) {
  songListPage()
}

