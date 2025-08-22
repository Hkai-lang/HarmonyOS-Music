import { songBean } from "../bean/songBean"
import { AVPlayerUtils } from "../utils/AVPlayerUtils"
import { CommonUtils } from "../utils/CommonUtils"
import { EventContanst } from "../utils/EventContanst"
import { getInternetImgColor } from "../utils/ImageUtils"
import { SharePreferenceUtil } from "../utils/SharePreferenceUtil"
import { SongUtils } from "../utils/SongUtils"

@Component
export struct favNearPage {
  pageInfo: NavPathStack = new NavPathStack()
  @StorageLink('likeList') likeList: songBean[] = []
  @StorageLink('nearList') nearList: songBean[] = []
  @State title: string = ''
  @State songList: songBean[] = []

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Row() {
            Image($rawfile('back.png'))
              .width(35)
              .height(35)
              .draggable(false)
              .margin({left:-10})
              .onClick(() => {
                AppStorage.setOrCreate('isSongList', false)
                this.pageInfo.pop()
              })

            Text(this.title)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)



          }.width('100%')
          .margin({ top: 50 })

          List({ space: 10 }) {
            ForEach(this.songList, (item: songBean, index ?: number) => {
              ListItem() {
                this.songItem(item)
              }

            })


          }.margin({ top: 20, bottom: 165 })
          .width('100%')
          .scrollBar(BarState.Off)

        }.width('90%')
      }.width('100%')

    }.onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack
      let param: object = new Object()
      param = this.pageInfo.getParamByName('favNearPage')[0] as object
      this.title = param['title']
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
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

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
    .onClick(() => {
      getInternetImgColor(songInfo.pic).then((color) => {

        songInfo.backgroundColor = color
        AppStorage.setOrCreate('nowSong', songInfo)
        SongUtils.zuiJin(songInfo, this.nearList)
        AppStorage.setOrCreate('isExpanded', true)
        AppStorage.setOrCreate('geDan', this.likeList)
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
export function favNearBuilder(name: string, param: object) {
  favNearPage()
}