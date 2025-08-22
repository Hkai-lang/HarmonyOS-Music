import { songBean } from "../bean/songBean";
import { CommonUtils } from "../utils/CommonUtils";
import { CustomTransitionUtils } from "../utils/CustomTransitionUtils";
import { EventContanst } from "../utils/EventContanst";
import { HttpUtils } from "../utils/HttpUtils";
import { HomePage } from "./HomePage";
import { playingPage } from "./playingPage";
import { SongWordsPage } from "./SongwordsPage";


@Component
export struct SongPlayingPage {
  @State pageInfo: NavPathStack = new NavPathStack()
  @State translateY: string = '0';
  @State pageId: string = '';
  @StorageLink('nowSong') nowSong: songBean = new songBean()
  @State currentIndex: number = 0
  private swiperController: SwiperController = new SwiperController();
  @StorageLink('wordMap') wordMap: Map<string, string> = new Map()
  @StorageLink('lyricsList') lyricsList: string [] = [] // 用于存储歌词的数组
  @State isManYou: boolean = false

  registerCallback() {
    CustomTransitionUtils.getInstance().registerNavParam(this.pageId,
      // 设置转场动画起点，根据不同的转场类型分别设置
      (isPush: boolean, isExit: boolean) => {
        if (isPush) {
          if (isExit) {
            this.translateY = '0';
          } else {
            this.translateY = '100%';
          }
        } else {
          if (isExit) {
            this.translateY = '0';
          } else {
            this.translateY = '0';
          }
        }
      },
      // 设置转场动画终点，根据不同的转场类型分别设置
      (isPush: boolean, isExit: boolean) => {
        if (isPush) {
          if (isExit) {
            this.translateY = '0';
          } else {
            this.translateY = '0';
          }
        } else {
          if (isExit) {
            this.translateY = '100%';
          } else {
            this.translateY = '0';
          }
        }
      });
  }

  build() {

    NavDestination() {

      Stack({ alignContent: Alignment.TopStart }) {
        Swiper(this.swiperController) {
          playingPage({
            pageInfo: this.pageInfo,
            lyricsList: this.lyricsList,
            isManYou: this.isManYou
          })
          SongWordsPage({
            lyricsList: this.lyricsList
          })


        }
        .width('100%')
        .height('100%')
        .indicator(
          new DotIndicator()
            .color(Color.Gray)
            .selectedColor(Color.Black)
            .top(30)
        )
        .index(this.currentIndex)
        .loop(false)
        .onChange((index: number) => {
          this.currentIndex = index;
        })

        Row() {
          Image($rawfile('down_black.png')).width(25).height(25).draggable(false)
            .onClick(() => {
              this.pageInfo.pop(this.pageId)
            })
        }.width('100%')
        .margin({ left: 25, top: 35 })
      }.width('100%')
      .height('100%')

    }
    .linearGradient({
      colors: [[0xffffff, 0.0], [0xffffff, 0.7], [this.nowSong.backgroundColor, 1.0]],
      direction: GradientDirection.Bottom
    })
    // .backgroundColor(this.nowSong.backgroundColor)
    .hideTitleBar(true)
    .translate({ y: this.translateY })
    .onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack;
      if (context.navDestinationId) {
        this.pageId = context.navDestinationId;
        // 页面创建时注册自定义转场动画参数
        this.registerCallback();
      }
      let param: object = this.pageInfo.getParamByName('songPlayingPage')[0] as object
      this.isManYou = param['isManYou']
    })
    .onDisAppear(() => {
      // 页面销毁时解注册自定义转场动画参数
      CustomTransitionUtils.getInstance().unRegisterNavParam(this.pageId);
    })

  }
}

@Builder
export function songPLayingBuilder(name: string, param: object) {
  SongPlayingPage()
}