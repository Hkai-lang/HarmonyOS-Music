import { songBean } from "../bean/songBean"
import { SongUtils } from "../utils/SongUtils"


@Component
export struct songListItem {
  @Prop songInfo: songBean
  @Prop index: number
  @StorageLink('likeList') likeList: songBean[] = []

  build() {
    Row() {

      Text(`${this.index + 1}`)
        .fontSize(20)
        .width(28)
        .height(28)
        .textAlign(TextAlign.Center)
      Column() {
        Text(this.songInfo.name)
          .fontSize(19)
          .fontColor(Color.Black)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.songInfo.artist)
          .fontSize(14)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }.height('100%')
      .width(0)
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ left: 18 })

      Image($rawfile((this.likeList.some(data => data.id === this.songInfo.id) && this.likeList) ? 'like.png' :
        'unlike.png'))
        .width(20)
        .height(20)
        .objectFit(ImageFit.Fill)
        .margin({ left: 40 })
        .draggable(false)
        .onClick(()=>{
          SongUtils.likeSong(this.songInfo,this.likeList)
        })


    }.height(50)
    .width('90%')
    .alignItems(VerticalAlign.Center)
    .margin({ top: 15 })

  }
}