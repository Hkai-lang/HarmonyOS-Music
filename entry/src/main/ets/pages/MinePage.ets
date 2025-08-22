import { songBean } from "../bean/songBean"

@Component
export struct MinePage {
  pageInfo: NavPathStack = new NavPathStack()
  @StorageLink('nearList') nearList: songBean[] = []
  @StorageLink('likeList') likeList: songBean[] = []

  build() {
    Navigation(this.pageInfo) {
      Scroll() {
        Column() {
          Image($rawfile('touxiang.JPG'))
            .width(110)
            .height(110)
            .borderRadius(200)

          Text('用户1129')
            .fontWeight(FontWeight.Bold)
            .fontSize(25)
            .margin({ top: 25 })

          Column({ space: 10 }) {
            //TODO 后续变成动态List

            //我喜欢的音乐歌单
            Row() {
              Stack() {
                Image(this.likeList[0].pic)
                  .width(55)
                  .height(55)
                  .borderRadius(4)
                Image($rawfile('unlike.png'))
                  .width(25)
                  .height(25)
              }

              Column({ space: 5 }) {
                Text('我喜欢的音乐')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)

                Text(`${this.likeList.length}首`)
                  .fontSize(13)
                  .fontColor('#858189')


              }.margin({ left: 10 })
              .alignItems(HorizontalAlign.Start)

            }.width('100%')
            .onClick(()=>{
              let param:object = new Object()
              param['title'] = '收藏歌单'
              param['list'] = this.likeList
              this.pageInfo.pushPath({name:'favNearPage',param:param})

            })



            Row() {

              Image(this.nearList[0].pic)
                .width(55)
                .height(55)
                .borderRadius(4)


              Column({ space: 5 }) {
                Text('最近')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)

                Text(`${this.nearList.length}首`)
                  .fontSize(13)
                  .fontColor('#858189')

              }.margin({ left: 10 })
              .alignItems(HorizontalAlign.Start)

            }.width('100%')
            .onClick(()=>{
              let param:object = new Object()
              param['title'] = '最近歌单'
              param['list'] = this.nearList
              this.pageInfo.pushPath({name:'favNearPage',param:param})


            })

          }.width('100%')

          .margin({ top: 20 })

        }.margin({ top: 90 })
        .width('90%')
        .height('100%')
      }.width('100%')
      .scrollBar(BarState.Off)

    }.width('100%')
    .height('100%')
    .backgroundColor('#F0F5F6')
  }
}