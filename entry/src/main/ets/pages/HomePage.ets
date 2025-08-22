import {
  findMaxPixel,
  getColor,
  getColorLocal,
  getInternetImgColor,
  image2PixelMap,
  modifySVValue,
  traverseAllPixel
} from "../utils/ImageUtils";
import { ColorHsv, ColorRgb, ColorUtils } from "../utils/ColorUtils";
import { CommonUtils } from "../utils/CommonUtils";
import { EventContanst } from "../utils/EventContanst";
import { songBean } from "../bean/songBean";
import { songItem } from "../item/songItem";
import hilog from "@ohos.hilog";
import { SharePreferenceUtil } from "../utils/SharePreferenceUtil";
import { BusinessError } from "@kit.BasicServicesKit";
import { AVPlayerUtils } from "../utils/AVPlayerUtils";
import { SongUtils } from "../utils/SongUtils";


@Component
export struct HomePage {
  pageInfo: NavPathStack = new NavPathStack()
  @Prop time: string
  @Prop imgArray: Array<imgInfoBean>
  @Prop imgSingerArray: Array<imgInfoBean>
  @State isPlaying: boolean = false
  isUseInterception: boolean = false;
  @Prop songList: songBean
  @Prop songArray: Array<songBean>
  @Prop imgBannerArray: Array<imgInfoBean>
  listController: ListScroller = new ListScroller();
  @Prop songTop: Map<string, songBean[]>
  @Prop songListRe: Map<string, songBean[]>
  @StorageLink('nearList') nearList: songBean[] = []

  aboutToAppear(): void {

    getColor(this.imgArray).then((data) => {
      this.imgArray = data
    })
    if (this.time !== undefined) {
      let da: Number = new Number(this.time.slice(11, 13))
      if (da > 13 && da < 17) {
        this.time = '下午好'
      } else if (da >= 17) {
        this.time = '晚上好'
      } else if (da > 10 && da <= 13) {
        this.time = '中午好'
      } else if (da < 9) {
        this.time = '早上好'
      } else {
        this.time = '上午好'
      }
    }
    this.pageInfo.setInterception({
      willShow: (from: NavDestinationContext | NavBar, to: NavDestinationContext | NavBar,
        operation: NavigationOperation, animated: boolean) => {
        if (to === "navBar") {
          CommonUtils.postEvent(EventContanst.showBar, '', 'true')
        }
      }
    })
  }

  build() {

    Navigation(this.pageInfo) {

      //顶部搜索框 --start
      Row() {
        Image($r('app.media.search'))
          .width(23)
          .height(23)
          .margin({ left: 10 })
          .draggable(false)

        Text('输入歌曲名或歌手')
          .backgroundColor('#FEFEFF')
          .width('70%')
          .textAlign(TextAlign.Center)


      }
      .width('80%')
      .height(40)
      .borderRadius(25)
      .backgroundColor('#FEFEFF')
      .margin({ top: 50 })
      .onClick(() => {
        this.pageInfo.pushPathByName('SearchPage', null)
        AppStorage.setOrCreate('isSongList', true)
        CommonUtils.postEvent(EventContanst.showBar, '', 'false')
      })

      //顶部搜索框 -- end

      Scroll() {
        Column() {
          // 第一部分 -- start
          Column() {

            Text(this.time)
              .fontSize(30)
              .fontColor(Color.Black)
              .fontWeight(FontWeight.Bold)
              .margin({ left: 15 })
              .width('100%')
              .textAlign(TextAlign.Start)

            Row() {
              List() {
                ForEach(this.imgArray, (item: imgInfoBean, index: number) => {
                  ListItem() {
                    homeTopListItem({
                      item: item,
                      isPlaying: this.isPlaying,
                      songTop: this.songTop
                    })

                  }.onClick(() => {
                    let param: object = new Object()
                    param['name'] = item.name
                    param['list'] = this.songTop.get(item.name)
                    if (item.name === '每日推荐') {
                      param['img'] = 'songList-backGround.gif'
                      param['text'] = '青春的爱情就是对话框里反复输入又删除的忐忑'
                      param['auth'] = '——来自网友yanranluo2的评论'
                    } else if (item.name === '热歌速递') {
                      param['img'] = 'songList_back2.gif'
                      param['text'] = '早知道嫁给你这么好，拍结婚照那一天我就多笑笑了。'
                      param['auth'] = '——来自网友君乃酒中仙的评论'
                    } else if (item.name === '私人雷达') {
                      param['img'] = 'songList_back3.gif'
                      param['text'] = '这个人的声音总有一种柔柔的，忧郁的感觉，像一场连绵的梅雨。'
                      param['auth'] = '——来自网友小谷桉桉的评论'
                    } else if (item.name === '新歌首发') {
                      param['img'] = 'songList_back4.gif'
                      param['text'] = '有些人十年如一日待你，有些人一日如十年，有些人十年转瞬不留。'
                      param['auth'] = '——来自网友人哪能不吃饭的评论'
                    }

                    this.pageInfo.pushPath({ name: 'songListPage', param: param })
                    AppStorage.setOrCreate('isSongList', true)
                    // this.pageInfo.pushDestination({name:'songListPage'})
                    CommonUtils.postEvent(EventContanst.showBar, '', 'false')

                  })
                  .margin({ left: index === 0 ? 15 : 10 })

                })
              }.listDirection(Axis.Horizontal)
              .scrollBar(BarState.Off)

            }.width('100%')
            .height(200)
            .margin({ top: 15 })

          }.width('100%')
          .margin({ top: 20 })

          // 第一部分 -- end

          //第二部分banner --start
          Column() {
            Swiper() {
              ForEach(this.imgBannerArray, (item: imgInfoBean, index: number) => {
                Image($rawfile(item.icon)).objectFit(ImageFit.Fill)
                  .borderRadius(5).draggable(false)
              })

            }.autoPlay(true)
            .indicator(
              new DotIndicator()
                .color(Color.Gray)
                .selectedColor(Color.White)
            )

          }.margin({ top: 20 })
          .width('92%')
          .height('150vp')

          //第二部分banner --end

          // 第三部分 -- start
          Column() {
            Text('您可能感兴趣的歌手')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
              .margin({ left: 15 })

            Row() {
              List() {
                ForEach(this.imgSingerArray, (item: imgInfoBean, index?: number) => {
                  ListItem() {
                    singerItem({
                      item: item,
                      isPlaying: this.isPlaying
                    })
                  }.margin({ left: index === 0 ? 15 : 10 })
                  .onClick(() => {
                    let param: object = new Object()
                    let list: songBean[] = this.songListRe.get(item.name)!

                    if (list) {
                      getInternetImgColor(list[0].pic).then((color) => {
                        list[0].backgroundColor = color
                        param['list'] = list
                        this.pageInfo.pushPath({ name: 'songListPage2', param: param })
                        AppStorage.setOrCreate('isSongList', true)
                        CommonUtils.postEvent(EventContanst.showBar, '', 'false')
                      })
                    }


                  })
                })

              }.listDirection(Axis.Horizontal)
              .scrollBar(BarState.Off)
              .height('150vp')
              .width('100%')

            }.width('100%')
            .margin({ top: 15 })
          }.margin({ top: 20 })
          .width('100%')

          // 第三部分 -- end

          //第四部分 -- start
          Column() {
            Text('猜您想听')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
              .margin({ left: 15 })

            Swiper() {
              ForEach(this.songArray, (songList: songBean[], index?: number) => {
                ListItem() {
                  this.songListItem(songList)
                }
              })

            }
            .width('100%')
            .margin({ top: 15 })
            .autoPlay(false)
            .indicator(false)

          }.width('100%')

          .margin({ top: 20 })

          //第四部分 -- end
        }.height('100%')
        .width('100%')

      }
      .height('138%')
      .width('100%')
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
      .enableScrollInteraction(true)

    }
    .height('100%')
    .width('100%')

  }

  @Builder
  songListItem(songList: songBean[]) {
    List({ space: 5 }) {
      ForEach(songList, (item: songBean, index: number) => {
        if (index <= 3) {
          ListItem() {
            songItem({
              songInfo: item
            })
          }.onClick(() => {

            getInternetImgColor(item.pic).then((color) => {

              item.backgroundColor = color
              AppStorage.setOrCreate('nowSong', item)
              AppStorage.setOrCreate('isExpanded', true)
              AppStorage.setOrCreate('geDan', songList)
              SongUtils.zuiJin(item,this.nearList)
              CommonUtils.postEvent(EventContanst.songWords, '', 'next')
              SharePreferenceUtil.getInstance().putString('lastSong', JSON.stringify(item))
              setTimeout(() => {
                AppStorage.setOrCreate('isExpanded', false)
              }, 5000)

              AVPlayerUtils.getInstance().play(item.url)

            })


          })
        }
      })
    }.listDirection(Axis.Vertical)
    .width('92%')
    .scrollBar(BarState.Off)
    .enableScrollInteraction(false)

  }
}

@Component
struct homeTopListItem {
  @ObjectLink item: imgInfoBean
  @Prop isPlaying: boolean
  @Prop songTop: Map<string, songBean[]>

  build() {

    Column() {
      Stack() {
        Image($rawfile(this.item.icon)).objectFit(ImageFit.Fill)
          .borderRadius({ topLeft: 8, topRight: 8 }).draggable(false)

        Text(this.item.name).fontColor(Color.White).fontWeight(FontWeight.Bold).fontSize(20)

        Column() {
          Blank()
          //TODO 后续优化
          // Image($rawfile(this.isPlaying ? 'playing.gif' : 'bofang.png'))
          //   .width(20)
          //   .height(20)
          //   .draggable(false)
          //   .objectFit(ImageFit.Fill)
          //   .margin({ bottom: 10, right: 10 })
          //   .onClick(() => {
          //     let songInfo: songBean[] | undefined = this.songTop!.get(this.item.name)
          //
          //
          //   })

        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.End)
        .alignSelf(ItemAlign.End)
        .alignItems(HorizontalAlign.End)

      }.width('100%').height(160)

      Text(this.item.description)
        .fontColor(Color.White)
        .fontSize(15)
        .height(40)
        .width('100%')
        .textAlign(TextAlign.Center)

    }.backgroundColor(this.item.backgroundColor === '' ? Color.White : this.item.backgroundColor)
    .width(150).height(200).borderRadius(8)
  }
}

@Component
struct singerItem {
  @Prop item: imgInfoBean
  @Prop isPlaying: boolean

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($rawfile(this.item.icon))
        .objectFit(ImageFit.Fill)
        .borderRadius(5)
        .draggable(false)

      RelativeContainer() {

        Text(this.item.name)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bolder)
          .fontSize(15)
          .alignRules({
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
            left: { anchor: "__container__", align: HorizontalAlign.Start }
          })

        Image($rawfile(this.isPlaying ? 'playing.gif' : 'bofang.png'))
          .width(20)
          .height(20)
          .draggable(false)
          .objectFit(ImageFit.Fill)
          .alignRules({
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
            right: { anchor: "__container__", align: HorizontalAlign.End }
          })
          .onClick(() => {
            if (this.isPlaying) {
              this.isPlaying = false
            } else {
              this.isPlaying = true

            }
          })
      }.width('100%')
      .padding(10)

    }.height(150)
    .width(150)

  }
}


@Observed
export class imgInfoBean {
  icon: string = '';
  backgroundColor: ResourceColor = '';
  name: string = ''
  description: string = ''

  constructor(icon: string, name: string, description: string) {
    this.icon = icon
    this.name = name
    this.description = description;

  }
}




