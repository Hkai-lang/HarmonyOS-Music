import { songBean } from "../bean/songBean"
import { CommonUtils } from "../utils/CommonUtils"
import { EventContanst } from "../utils/EventContanst"
import { LengthMetrics } from "@kit.ArkUI"
import { AVPlayerUtils } from "../utils/AVPlayerUtils"
import { hilog } from "@kit.PerformanceAnalysisKit"

@Component
export struct SongWordsPage {
  @Prop lyricsList: string []
  @StorageLink('nowSong') nowSong: songBean = new songBean()
  private listController = new ListScroller()
  @StorageLink('isPlaying') isPlaying: boolean = false
  @StorageLink('yOffset') yOffset: number = 0
  @StorageLink('currentLyricIndex') currentLyricIndex: number = 0

  aboutToAppear(): void {

    CommonUtils.handleEvent(EventContanst.songWords, (result: Record<string, string>) => {
       if (result['message'] === 'update') {
         hilog.debug(1,'wyp111','更新歌词songWordsPage : '+this.yOffset)
        this.listController.scrollTo({ xOffset: 0, yOffset: this.yOffset ,animation:true}); // smooth 表示平滑滚动
      }
    })
  }


  build() {
    Column() {
      if (this.lyricsList.length > 0) {
        Row() {
          Column() {
            Text(this.nowSong.name).fontSize(25).fontWeight(FontWeight.Bold).letterSpacing(3)
            Text(this.nowSong.artist).fontSize(16)
          }.alignItems(HorizontalAlign.Start)
          .width(0)
          .layoutWeight(1)

          //todo 后续右侧加入收藏功能
        }.width('100%')
        .height(98)

        List({ initialIndex: this.currentLyricIndex, scroller: this.listController, space: 12 }) {
          ForEach(this.lyricsList, (item: string, index: number) => {
            ListItem() {
                Text(item)
                  .fontSize(index === this.currentLyricIndex ? 23 : 18)
                  .fontColor(index === this.currentLyricIndex ? Color.Red : Color.Black)
                  .fontWeight(index === this.currentLyricIndex ? FontWeight.Bold : FontWeight.Normal)

            }.height(30)

          })

        }.scrollBar(BarState.Off)
        .fadingEdge(true, { fadingEdgeLength: LengthMetrics.vp(60) })
        .height('500vp')

        Row() {
          Blank().width(0).layoutWeight(1)
          Image($rawfile(this.isPlaying ? 'zanting-2.png' : 'bofang-2.png'))
            .width(50)
            .height(50)
            .margin({ right: 10 })
            .onClick(() => {
              if (this.isPlaying) {
                this.isPlaying = false
                AVPlayerUtils.getInstance().play(this.nowSong.url)
                return
              }
              this.isPlaying = true
              AVPlayerUtils.getInstance().play(this.nowSong.url)

            })
        }.width('100%')
        .margin({ top: 20 })

      } else {
        Text('暂无歌词')
          .fontSize(20)
          .fontColor(Color.Black)
      }
    }.height('100%')
    .width('100%')
    .margin({ top: 70, left: 30 })
  }
}