import { songBean } from "../bean/songBean"
import { SharePreferenceUtil } from "../utils/SharePreferenceUtil"
import { SongUtils } from "../utils/SongUtils"

@Component
export struct songItem {
  @Prop songInfo: songBean
  @StorageLink('likeList') likeList: songBean[] = []

  build() {
    Row() {
      Image(this.songInfo.pic)
        .objectFit(ImageFit.Fill)
        .width(57)
        .height(57)
        .borderRadius(4)
        .draggable(false)

      Column() {
        Text(this.songInfo.name).fontSize(16).fontWeight(FontWeight.Bold)

        Text(`${this.songInfo.artist}-${this.songInfo.name}`).fontSize(12)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 5 })
      .height(57)
      .width(0)
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceAround)

      Image($rawfile((this.likeList.some(song => song.id === this.songInfo.id) && this.likeList) ? 'like.png' :
        'unlike.png'))
        .width(20)
        .height(20)
        .alignSelf(ItemAlign.Center)
        .draggable(false)
        .onClick(() => {
          SongUtils.likeSong(this.songInfo, this.likeList)
        })
    }.width('100%')

  }
}