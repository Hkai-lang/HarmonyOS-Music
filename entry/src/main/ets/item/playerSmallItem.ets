import { songBean } from "../bean/songBean"
import { AVPlayerUtils } from "../utils/AVPlayerUtils"
import { CommonUtils } from "../utils/CommonUtils"
import { EventContanst } from "../utils/EventContanst"
import { SharePreferenceUtil } from "../utils/SharePreferenceUtil"
import { SongUtils } from "../utils/SongUtils"

@Component
export struct playerSmallItem {
  @Prop songInfo: songBean
  @Link isPlaying: boolean
  @Prop isExpand: boolean
  @State isFinish: boolean = false
  @Prop songPlayingTime: number
  @Link songCurrentTime: string
  @StorageLink('currentLyricIndex') currentLyricIndex: number = 0
  private listController = new ListScroller()
  @StorageLink('updateSongWords') yOffset: number = 0
  @StorageLink('lyricsList') lyricsList: string [] = [] // 用于存储歌词的数组
  @Prop geDanSongArray: songBean[]
  @StorageLink('likeList') likeList: songBean[] = []

  aboutToAppear(): void {
    CommonUtils.handleEvent(EventContanst.songWords, (result: Record<string, string>) => {
      if (result['message'] === 'update') {
        this.listController.scrollTo({ xOffset: 0, yOffset: this.yOffset }); // smooth 表示平滑滚动
      }
    })
  }

  build() {
    Column() {

      Row() {
        Stack() {
          Image($rawfile("image_back.png"))
            .width(this.isExpand ? 100 : 60)
            .height(this.isExpand ? 200 : 105)
            .margin({ left: this.isExpand ? 50 : 18 })
            .draggable(false)

          Image(this.songInfo.pic)
            .width(this.isExpand ? 95 : 50)
            .height(this.isExpand ? 95 : 50)
            .borderRadius(5)
            .margin({ left: this.isExpand ? 20 : 0 })
            .draggable(false)
            .animation({
              duration: this.isExpand ? 100 : 300,
              curve: Curve.EaseOut,
              onFinish: () => {
                this.isFinish = true
              }
            })
        }.width(this.isExpand ? 120 : 50)
        .height(this.isExpand ? 95 : 50)
        .animation({
          duration: this.isExpand ? 200 : 300,
          curve: Curve.EaseOut,
        })


        if (this.isExpand && this.isFinish) {
          Column() {
            Text(`${this.songInfo.name}`)
              .fontSize(15)
              .fontWeight(FontWeight.Bolder)
              .textOverflow({ overflow: TextOverflow.MARQUEE })
            Text(`${this.songInfo.artist}`).fontSize(13).margin({ top: 5 })

            List({ initialIndex: this.currentLyricIndex, scroller: this.listController }) {
              ForEach(this.lyricsList, (item: string, index: number) => {
                ListItem() {
                  Text(item)
                    .fontSize(13)
                    .fontColor(Color.Gray)
                    .textOverflow({ overflow: TextOverflow.MARQUEE })
                }.height('100%')
                .width('100%')
                .align(Alignment.Start)

              })
            }.width(110)
            .height(30)
            .scrollBar(BarState.Off)
            .margin({ top: 8 })

          }.width(160)
          .margin({ left: 25, top: 15 })
          .alignItems(HorizontalAlign.Start)

          Image($rawfile("down.png"))
            .width(45)
            .height(45)
            .draggable(false)
            .margin({ top: -30, right: -5 })
            .onClick(() => {
              AppStorage.setOrCreate('isExpanded', false)
            })

        } else {
          Text(`${this.songInfo.name} - ${this.songInfo.artist}`)
            .width(200)
            .fontSize(13)
            .textOverflow({ overflow: TextOverflow.MARQUEE })
            .margin({ left: 20 })
          Stack() {
            Image(this.isPlaying ? $rawfile("pause.png") : $rawfile('bofang_black.png'))

              .draggable(false)


            Progress({ value: this.songPlayingTime, total: this.songInfo.duration, type: ProgressType.Ring }).width(28)
              .height(28)
              .color(Color.Black)
              .style({ strokeWidth: 2 })
          }.width(30)
          .height(30)
          .margin({ left: 10 })
          .onClick(() => {
            // this.play(this.songInfo!)
            if (this.isPlaying) {
              AppStorage.setOrCreate('isPlaying', false)
              CommonUtils.postEvent(EventContanst.songWords, '', 'pause')
              AVPlayerUtils.getInstance().play(this.songInfo.url)
            } else {
              AppStorage.setOrCreate('isPlaying', true)
              CommonUtils.postEvent(EventContanst.songWords, '', 'continue')
              //暂停
              AVPlayerUtils.getInstance().play(this.songInfo.url)
            }
          })

          Image($rawfile("gedan.png"))
            .width(30)
            .height(30)
            .margin({ left: 10 })
            .draggable(false)
            .onClick(() => {
              CommonUtils.postEvent(EventContanst.geDan)
            })
        }


      }
      .width('100%')
      .height(this.isExpand ? 95 : '100%')
      .margin({ top: this.isExpand ? -10 : 0 })

      if (this.isExpand && this.isFinish) {
        Slider({
          min: 0,
          max: this.songInfo.duration,
          value: this.songPlayingTime,
        })

          .width('90%')
          .height(5)
          .blockColor(Color.Black)
          .blockSize({ width: 10, height: 10 })
          .selectedColor(Color.Black)
          .onChange((value: number, mode: SliderChangeMode) => {
            AppStorage.setOrCreate('songPlayingTime', value)
            AppStorage.setOrCreate('songCurrentTime', CommonUtils.convertMillisecondsToTime(value))
            AVPlayerUtils.getInstance().seek(value)
          })
          .margin({ top: 20, bottom: 5 })

        Row() {
          Text(this.songCurrentTime ? this.songCurrentTime : '00:00').fontColor(Color.Gray).fontSize(10).width(0)
            .layoutWeight(1)
          Text(this.songInfo.songDurationFinal).fontColor(Color.Gray).fontSize(10)
        }
        .width('87%')

        Row() {
          Image($rawfile((this.likeList.some(song => song.id === this.songInfo.id) && this.likeList) ? 'like.png' :
            'unlike.png'))
            .width(23).height(23).draggable(false)
            .onClick(()=>{
              SongUtils.likeSong(this.songInfo, this.likeList)
            })
          Image($rawfile("shangyiqu.png")).width(25).height(25).draggable(false)
            .onClick(() => {
              AVPlayerUtils.getInstance().qieGe(false, this.geDanSongArray, this.songInfo, true)
            })
          Image($rawfile(this.isPlaying ? "pause.png" : "bofang_black.png")).width(35).height(35)
            .draggable(false)
            .onClick(() => {
              if (this.isPlaying) {
                AppStorage.setOrCreate('isPlaying', false)
                CommonUtils.postEvent(EventContanst.songWords, '', 'pause')
                AVPlayerUtils.getInstance().play(this.songInfo.url)
              } else {
                AppStorage.setOrCreate('isPlaying', true)
                CommonUtils.postEvent(EventContanst.songWords, '', 'pause')
                AVPlayerUtils.getInstance().play(this.songInfo.url)

              }

            })

          Image($rawfile("xiayiqu.png")).width(25).height(25).draggable(false)
            .onClick(() => {
              AVPlayerUtils.getInstance().qieGe(true, this.geDanSongArray, this.songInfo, true)
            })

          Image($rawfile("gedan.png")).width(30).height(30).draggable(false).onClick(() => {
            CommonUtils.postEvent(EventContanst.geDan)
            AppStorage.setOrCreate('isExpand', false)
            CommonUtils.postEvent(EventContanst.showBar, '', 'allDown')


          })

        }.width('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .margin({ top: 15 })
      }


    }
    .width('100%')
    .height('100%')
    .border({ radius: this.isExpand ? 10 : 25 })
    .backgroundColor(this.songInfo.backgroundColor)
    .gesture(LongPressGesture({ repeat: true }).onAction((event: GestureEvent | undefined) => {
      if (event) {
        if (!this.isExpand) {
          AppStorage.setOrCreate('isExpanded', true)
          setTimeout(() => {
            AppStorage.setOrCreate('isExpanded', false)
          }, 5000)
        }
      }
    }))

  }
}