import { songBean } from "../bean/songBean"
import { AVPlayerUtils } from "../utils/AVPlayerUtils"
import { CommonUtils } from "../utils/CommonUtils"
import { EventContanst } from "../utils/EventContanst"
import { SharePreferenceUtil } from "../utils/SharePreferenceUtil"
import { SongUtils } from "../utils/SongUtils"

@Component
export struct playingPage {
  @Link pageInfo: NavPathStack
  @StorageLink('isPlaying') isPlaying: boolean = false
  @StorageLink('nowSong') nowSong: songBean = new songBean()
  @State playRotate: number = 0
  @StorageLink('songPlayingTime') songPlayingTime: number = 0
  @StorageLink('songCurrentTime') songCurrentTime: string = ''
  @Prop lyricsList: string []
  @StorageLink('updateSongWords') yOffset: number = 0
  @StorageLink('currentLyricIndex') currentLyricIndex: number = 0
  private listController = new ListScroller()
  @StorageLink('geDan') geDanSongArray: songBean[] = []
  @StorageLink('likeList') likeList: songBean[] = []
  @Prop isManYou: boolean

  aboutToAppear(): void {
    CommonUtils.handleEvent(EventContanst.songWords, (result: Record<string, string>) => {
      if (result['message'] === 'update') {
        this.listController.scrollTo({ xOffset: 0, yOffset: this.yOffset }); // smooth 表示平滑滚动
      }
    })

    CommonUtils.handleEvent(EventContanst.isFinish, (result: Record<string, string>) => {
      AVPlayerUtils.getInstance().qieGe(true, this.geDanSongArray, this.nowSong, false)
    })
    //TODO 后续增加漫游歌单
    if (this.isManYou) {
      if (!this.isPlaying) {
        this.isPlaying = true
        AVPlayerUtils.getInstance().play(this.nowSong.url)
      }

    }

  }

  build() {
    Column() {

      Column() {
        Stack({ alignContent: Alignment.Top }) {

          Image($rawfile('play_style.png'))
            .width('90%')
            .height('45%')
            .draggable(false)
            .margin({ top: 20 })
            .objectFit(ImageFit.Contain)


          Image(this.nowSong.pic)
            .width(170)
            .height(170)
            .draggable(false)
            .objectFit(ImageFit.Contain)
            .borderRadius(200)
            .margin({ top: 124 })
            .rotate({
              x: 0,
              y: 0,
              z: 1,
              angle: this.isPlaying ? this.playRotate : 0,
              centerX: '50%',
              centerY: '50%'
            })
            .animation({
              duration: 4000,
              curve: Curve.Linear,
              iterations: -1,
              playMode: PlayMode.Normal
            })
            .onAppear(() => {
              if (this.isPlaying) {
                this.playRotate = 360
                return
              }
              this.playRotate = 0

            })
            .onClick(() => {
              if (this.isPlaying) {
                AppStorage.setOrCreate('isPlaying', false)
                this.playRotate = 0
                return
              }
              this.playRotate = 360
              AppStorage.setOrCreate('isPlaying', true)

            })

          Image($rawfile('play_head.png'))
            .width(150)
            .height(120)
            .margin({ left: 120 })
            .objectFit(ImageFit.Contain)
            .rotate({
              angle: this.isPlaying ? 95 : 0,
              x: 0,
              y: 0,
              z: 1,
              centerX: '8%',
              centerY: '20%'
            })
            .draggable(false)
            .animation({
              duration: 500,
              playMode: PlayMode.Normal,
              curve: Curve.Linear,
              onFinish: () => {

              }
            })
        }.width('100%')

        Column() {
          Text(this.nowSong.name)
            .fontSize(30)
            .fontWeight(FontWeight.Bolder)
            .fontColor(Color.Black)
            .textOverflow({ overflow: TextOverflow.MARQUEE })
            .width(300)
          Text(this.nowSong.artist)
            .fontSize(19)
            .fontColor(Color.Gray)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 8 })
          List({ initialIndex: this.currentLyricIndex, scroller: this.listController }) {
            ForEach(this.lyricsList, (item: string, index: number) => {
              ListItem() {
                Text(item)
                  .fontSize(17)
                  .fontColor(Color.Black)
                  .textOverflow({ overflow: TextOverflow.MARQUEE })
              }.height('100%')

            })
          }.width('280vp')
          .height('30vp')
          .margin({ top: 16 })
          .scrollBar(BarState.Off)

        }.width('100%')
        .margin({ left: 30, top: 25 })
        .alignItems(HorizontalAlign.Start)

        Column() {
          Slider({
            min: 0,
            max: this.nowSong.duration,
            value: this.songPlayingTime,
          })
            .width('95%')
            .height(5)
            .blockColor(Color.Black)
            .blockSize({ width: 10, height: 10 })
            .selectedColor(Color.Black)// .blockStyle({ type: SliderBlockType.IMAGE, image: $r('app.media.huojian') })
            .onChange((value: number, mode: SliderChangeMode) => {
              AppStorage.setOrCreate('songPlayingTime', value)
              AppStorage.setOrCreate('songCurrentTime', CommonUtils.convertMillisecondsToTime(value))
              AVPlayerUtils.getInstance().seek(value)
            })

          Row() {
            Text(this.songCurrentTime ? this.songCurrentTime : '00:00').fontColor(Color.Gray).fontSize(12).width(0)
              .layoutWeight(1)
            Text(this.nowSong.songDurationFinal).fontColor(Color.Gray).fontSize(12)
          }
          .width('92%')
          .margin({ top: 5 })
        }.width('100%')
        .margin({ top: 50 })


        Row() {
          Image($rawfile((this.likeList.some(song => song.id === this.nowSong.id) && this.likeList) ? 'like.png' :
            'unlike.png'))
            .width(27).height(27).draggable(false)
            .onClick(() => {
              SongUtils.likeSong(this.nowSong, this.likeList)
            })

          Image($rawfile("shangyiqu.png")).width(30).height(30).draggable(false)
            .onClick(() => {
              AVPlayerUtils.getInstance().qieGe(false, this.geDanSongArray, this.nowSong, true)
            })
          Image($rawfile(this.isPlaying ? "pause.png" : "bofang_black.png")).width(50).height(50).draggable(false)
            .onClick(() => {

              if (this.isPlaying) {
                this.isPlaying = false
                this.playRotate = 0
                CommonUtils.postEvent(EventContanst.songWords, '', 'pause')
                AVPlayerUtils.getInstance().play(this.nowSong.url)

              } else {
                this.playRotate = 360
                this.isPlaying = true
                CommonUtils.postEvent(EventContanst.songWords, '', 'continue')
                AVPlayerUtils.getInstance().play(this.nowSong.url)

              }

            })

          Image($rawfile("xiayiqu.png")).width(30).height(30).draggable(false)
            .onClick(() => {
              AVPlayerUtils.getInstance().qieGe(true, this.geDanSongArray, this.nowSong, true)
            })
          Image($rawfile("gedan.png")).width(30).height(30).draggable(false)
            .onClick(() => {
              this.pageInfo.pushPath({ name: 'geDanPage' })
            })
        }.width('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .margin({ top: 15 })
      }
      .margin({ top: 80 })
      .height('100%')
    }.width('100%')
    .height('100%')

  }
}