import { HomePage, imgInfoBean } from "./HomePage";
import { MinePage } from "./MinePage";
import { SearchPage } from "./SearchPage";
import { curves, window } from "@kit.ArkUI";
import { BusinessError, systemDateTime } from "@kit.BasicServicesKit";
import { TimeUtil } from "../utils/TimeUtil";
import { HttpUtils } from "../utils/HttpUtils";
import { songBean } from "../bean/songBean";
import { CommonUtils } from "../utils/CommonUtils";
import { EventContanst } from "../utils/EventContanst";
import { barItemBean } from "../bean/barItemBean";
import { playerSmallItem } from "../item/playerSmallItem";
import { SharePreferenceUtil } from "../utils/SharePreferenceUtil";
import { CustomTransitionUtils } from "../utils/CustomTransitionUtils";
import { AVPlayerUtils } from "../utils/AVPlayerUtils";
import { playingPage } from "./playingPage";

@Entry
@Component
struct MainPage {
  tabController: TabsController = new TabsController();
  @State currentIndex: number = 0
  @State selectedIndex: number = 0
  @State currentTime: string = ''
  @State songList: songBean = new songBean()
  @State pageInfo: NavPathStack = new NavPathStack();
  @State barArray: Array<barItemBean> = []
  @State imgArray: Array<imgInfoBean> = []
  @State imgSingerArray: Array<imgInfoBean> = []
  @State imgBannerArray: Array<imgInfoBean> = []
  @StorageLink('isPlaying') isPlaying: boolean = false
  @State songArray: Array<songBean> = []
  @State private offsetY: number = 0;
  @State private opacityValue: number = 1;
  @State private downY: number = 0;
  @State private downOpacityValue: number = 1;
  @StorageLink('nowSong') nowSong: songBean = new songBean()
  @StorageLink('isExpanded') isExpanded: boolean = false;
  // 动画参数
  @State expandHeight: number = 0;
  @State pageId: string = '';
  //底部全部下滑状态
  @State allDown: boolean = false
  @StorageProp('songPlayingTime') songPlayingTime: number = 0
  @StorageProp('songCurrentTime') songCurrentTime: string = ''
  @StorageLink('geDan') geDanSongArray: songBean[] = []
  @StorageLink('wordMap') wordMap: Map<string, string> = new Map()
  @StorageLink('lyricsList') lyricsList: string [] = [] // 用于存储歌词的数组
  private intervalId ?: number | undefined; // 定时器ID
  @StorageLink('updateSongWords') yOffset: number = 0
  @StorageLink('likeList') likeList: songBean[] = []
  @State songTop: Map<string, songBean[]> = new Map() // 每日推荐，热歌速递，私人雷达，新歌首发
  @StorageLink('isSongList') isSongList: boolean = false
  @State songListRe: Map<string, songBean[]> = new Map() //感兴趣歌手歌单

  aboutToAppear(): void {
    this.getBarData()
    this.getNowTime()
    this.getSongList()
    this.makeData()
    this.makeSingerData()
    this.makeBannerData()
    SharePreferenceUtil.getInstance().createPreferences(this.getUIContext().getHostContext(), 'likeList')
    SharePreferenceUtil.getInstance().createPreferences(this.getUIContext().getHostContext(), 'songInfo')
    if (SharePreferenceUtil.getInstance().getString('lastSong')) {
      this.nowSong = JSON.parse(SharePreferenceUtil.getInstance().getString('lastSong'))
    }
    this.likeList = SharePreferenceUtil.getInstance().getSongBeans('likeList')
    this.getSongWords()

    CommonUtils.handleEvent(EventContanst.showBar, (result: Record<string, string>) => {
      if (result['message'] === 'true') {

        this.showWithAnimation()
        this.upWithAnimation()
      } else if (result['message'] === 'allDown') {
        this.allDown = true
        this.hideWithAnimation()
        this.downWithAnimation()
      } else if (result['message'] === 'allUp') {
        this.allDown = false
        this.showWithAnimation()
        this.upWithAnimation()
      } else if (result['message'] === 'false') {
        this.allDown = false
        this.hideWithAnimation()
        this.downWithAnimation()
      } else if (result['message'] === 'upOne') {
        this.upWithAnimation()
      }
    })

    CommonUtils.handleEvent(EventContanst.playSate, (result: Record<string, string>) => {
      this.isPlaying = AVPlayerUtils.getInstance().getPlayingState()
    })

    CommonUtils.handleEvent(EventContanst.geDan, () => {
      this.allDown = true
      this.downWithAnimation()
      this.hideWithAnimation()
      setTimeout(() => {
        this.pageInfo.pushPath({ name: 'geDanPage' })
      }, 100)
    })

    CommonUtils.handleEvent(EventContanst.isFinish, (result: Record<string, string>) => {
      AVPlayerUtils.getInstance().qieGe(true, this.geDanSongArray, this.nowSong, false)
      this.isExpanded = true
      setTimeout(() => {
        this.isExpanded = false
      }, 5000)
    })

    CommonUtils.handleEvent(EventContanst.songWords, (result: Record<string, string>) => {
      if (result['message'] === 'continue') {
        this.startTimer2()
      } else if ((result['message'] === 'seek')) {
        clearInterval(this.intervalId)
        AVPlayerUtils.getInstance().updateCurrentLyric(this.wordMap, this.songPlayingTime, 30)
        // this.updateCurrentLyric()
        this.startTimer2()
      } else if (result['message'] === 'pause') {
        clearInterval(this.intervalId)
      } else if (result['message'] === 'next') {
        if (this.wordMap.size !== 0) {
          this.wordMap.clear()
        }
        if (this.lyricsList.length !== 0) {
          this.lyricsList = []
        }
        this.getSongWords()
        clearInterval(this.intervalId)
        // AVPlayerUtils.getInstance().updateCurrentLyric(this.wordMap, this.songPlayingTime, 30)
        this.startTimer2()
      }
    })

  }

  getBarData() {
    const home: barItemBean = new barItemBean('shouYe.png', 'shouYeSelected.png', '首页')
    const search: barItemBean = new barItemBean('search.png', 'searchSelected.png', '漫游')
    const mine: barItemBean = new barItemBean('mine.png', 'mineSelected.png', '我的')
    this.barArray.push(home, search, mine)
  }

  /**
   * 音乐API服务模块
   *
   * 免责声明：
   * 1. 本模块仅用于技术学习和演示目的
   * 2. 所有音乐内容版权归原作者所有
   * 3. 用户需自行确保音乐内容的合法使用权
   * 4. 不得用于商业用途
   *
   * 使用本代码即表示您同意以上声明
   */
  getSongList() {
    HttpUtils.httpGetSong('https://music.cenguigui.cn/?server=netease&type=search&id=梁博').then((res) => {
      this.songList = JSON.parse(res) || new Object()
      this.songArray.push(this.songList)

      let list: songBean[] = JSON.parse(res) || new Object()
      this.songListRe.set('梁博', list)

    })
    HttpUtils.httpGetSong('https://music.cenguigui.cn/?server=netease&type=search&id=周杰伦').then((res) => {
      this.songList = JSON.parse(res) || new Object()
      this.songArray.push(this.songList)

      let list: songBean[] = JSON.parse(res) || new Object()
      this.songListRe.set('周杰伦', list)
    })
    HttpUtils.httpGetSong('https://music.cenguigui.cn/?server=netease&type=search&id=邓紫棋').then((res) => {
      this.songList = JSON.parse(res) || new Object()
      this.songArray.push(this.songList)

      let list: songBean[] = JSON.parse(res) || new Object()
      this.songListRe.set('邓紫棋', list)
    })
    HttpUtils.httpGetSong('https://music.cenguigui.cn/?server=netease&type=search&id=薛之谦').then((res) => {
      this.songList = JSON.parse(res) || new Object()
      this.songArray.push(this.songList)
    })

    HttpUtils.httpGetSong('https://music.cenguigui.cn/?server=netease&type=search&id=陈奕迅').then((res) => {
      let list: songBean[] = JSON.parse(res) || new Object()
      this.songTop.set('每日推荐', list)
      this.songListRe.set('陈奕迅', list)
    })

    HttpUtils.httpGetSong('https://music.cenguigui.cn/?server=netease&type=search&id=加木').then((res) => {
      let list: songBean[] = JSON.parse(res) || new Object()
      this.songTop.set('热歌速递', list)
    })

    HttpUtils.httpGetSong('https://music.cenguigui.cn/?server=netease&type=search&id=那英').then((res) => {
      let list: songBean[] = JSON.parse(res) || new Object()
      this.songTop.set('私人雷达', list)
    })

    HttpUtils.httpGetSong('https://music.cenguigui.cn/?server=netease&type=search&id=赵雷').then((res) => {
      let list: songBean[] = JSON.parse(res) || new Object()
      this.songTop.set('新歌首发', list)
    })

    HttpUtils.httpGetSong('https://music.cenguigui.cn/?server=netease&type=search&id=张靓颖').then((res) => {
      let list: songBean[] = JSON.parse(res) || new Object()
      this.songListRe.set('张靓颖', list)
    })


  }

  getSongWords() {
    HttpUtils.GetSongWords(this.nowSong.lrc).then((res) => {
      let data: object = JSON.parse(res) || new Object()
      let params: string = data['result']
      const lines: string[] = params.split('\n')
      const timeRegExp = /\[(\d{2}:\d{2}\.\d{2,3})\]/
      lines.forEach((line: string) => {
        const time = line.match(timeRegExp);
        if (time) {
          let wordTime: string = time[1]
          let lyricText = line.replace(timeRegExp, '').trim()
          if (lyricText !== '') {
            this.wordMap.set(wordTime, lyricText)
            this.lyricsList.push(lyricText)
          }

        }
      })
      console.info('wordMap is :' + this.wordMap)
    })
  }

  //暂停时，再次点击用的计时器
  startTimer2() {
    this.intervalId = setInterval(() => {
      // this.updateCurrentLyric()
      AVPlayerUtils.getInstance().updateCurrentLyric(this.wordMap, this.songPlayingTime, 30)

    }, 100);
  }

  aboutToDisappear() {
    if (this.intervalId && this.isPlaying == false) {
      clearInterval(this.intervalId);
    }
    SharePreferenceUtil.getInstance().putObjectArray('likeList', this.likeList)
  }

  // 显示动画（向上滑入）
  private showWithAnimation() {
    animateTo({
      duration: 300,
      curve: Curve.EaseOut
    }, () => {
      this.offsetY = 0;
      this.opacityValue = 1;
    });
  }

  // 隐藏动画（向下滑出）
  private hideWithAnimation() {
    animateTo({
      duration: 300,
      curve: Curve.EaseIn
    }, () => {
      this.offsetY = 88; // 向下移动距离（与高度一致）
      this.opacityValue = 0;
    });
  }

  // 显示动画（向上滑入）
  private upWithAnimation() {
    animateTo({
      duration: 300,
      curve: Curve.EaseOut
    }, () => {
      this.downY = this.isSongList ? 38 : 0;
      this.opacityValue = 1;
    });
  }

  // 动画（向下滑）
  private downWithAnimation() {
    animateTo({
      duration: 300,
      curve: Curve.EaseIn
    }, () => {
      this.downY = this.allDown ? 110 : 38; // 向下移动距离（与高度一致）
      this.opacityValue = this.allDown ? 0 : 1;
    });
  }

  makeData() {
    const everyday: imgInfoBean = new imgInfoBean('everyDay.png', '每日推荐', '符合你口味的新鲜好歌')
    const hotSong: imgInfoBean = new imgInfoBean('hotSong.png', '热歌速递', '从你喜欢的歌听起')
    const personal: imgInfoBean = new imgInfoBean('personal.png', '私人雷达', '你爱的歌值得反复聆听')
    const newSong: imgInfoBean = new imgInfoBean('newSong.png', '新歌首发', '你说爱的越深,心就越疼')
    this.imgArray.push(everyday, hotSong, personal, newSong)
  }

  makeSingerData() {
    const singer1: imgInfoBean = new imgInfoBean('chenyixun.png', '陈奕迅', '符合你口味的新鲜好歌')
    const singer2: imgInfoBean = new imgInfoBean('dengziqi.png', '邓紫棋', '从你喜欢的歌听起')
    const singer3: imgInfoBean = new imgInfoBean('liangbo.png', '梁博', '你爱的歌值得反复聆听')
    const singer4: imgInfoBean = new imgInfoBean('zhoujielun.png', '周杰伦', '你说爱的越深,心就越疼')
    const singer5: imgInfoBean = new imgInfoBean('zhangliangying.png', '张靓颖', '你说爱的越深,心就越疼')
    this.imgSingerArray.push(singer1, singer2, singer3, singer4, singer5)
  }

  makeBannerData() {
    const banner1: imgInfoBean = new imgInfoBean('banner1.png', 'banner1', 'banner1')
    const banner2: imgInfoBean = new imgInfoBean('banner2.png', 'banner2', 'banner2')
    const banner3: imgInfoBean = new imgInfoBean('banner3.png', 'banner3', 'banner3')
    this.imgBannerArray.push(banner1, banner2, banner3)
  }

  getNowTime() {
    let time = systemDateTime.getTime()
    this.currentTime = TimeUtil.formatTimestamp(time)
  }

  registerCallback() {
    CustomTransitionUtils.getInstance().registerNavParam(this.pageId,
      // 设置转场动画起点，根据不同的转场类型分别设置
      (isPush: boolean, isExit: boolean) => {
      },
      // 设置转场动画终点，根据不同的转场类型分别设置
      (isPush: boolean, isExit: boolean) => {
      });
  }

  build() {

    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {

        Tabs({ index: this.currentIndex, controller: this.tabController }) {
          ForEach(this.barArray, (item: barItemBean, index?: number) => {
            TabContent() {
              if (index === 0) {
                HomePage({
                  time: this.currentTime,
                  imgArray: this.imgArray,
                  imgSingerArray: this.imgSingerArray,
                  songArray: this.songArray,
                  imgBannerArray: this.imgBannerArray,
                  songTop: this.songTop,
                  songListRe: this.songListRe
                })
              } else if (index === 1) {

                // SearchPage()
              } else if (index === 2) {
                MinePage()
              }
            }
          })

        }
        .barHeight(0)
        .barWidth(0)
        .width('100%')
        .height('100%')
        .onChange((index: number) => {
          this.currentIndex = index
          this.selectedIndex = index
        })
        .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
          if (index === targetIndex) {
            return
          }
          // selectedIndex控制自定义TabBar内Image和Text颜色切换
          this.selectedIndex = targetIndex
        })
        .scrollable(false)


        Row() {
          ForEach(this.barArray, (item: barItemBean, index: number) => {
            this.tabBuild(item, index)

          })

        }
        .width('100%')
        .height('88vp')
        .backgroundColor(Color.White)
        .justifyContent(FlexAlign.SpaceAround)
        .alignItems(VerticalAlign.Bottom)
        .translate({ y: this.offsetY })
        .opacity(this.opacityValue)

        Column() {

          playerSmallItem({
            songInfo: this.nowSong,
            isPlaying: this.isPlaying,
            isExpand: this.isExpanded,
            songPlayingTime: this.songPlayingTime,
            songCurrentTime: this.songCurrentTime,
            geDanSongArray: this.geDanSongArray
          })

            .onClick(() => {
              this.allDown = true
              if (this.isExpanded) {
                this.isExpanded = false
              }
              this.downWithAnimation()
              this.hideWithAnimation()
              setTimeout(() => {
                let param: object = new Object()
                param['isManYou'] = false
                this.pageInfo.pushPath({ name: 'songPlayingPage',param:param })

              }, 100)
            })


        }
        .margin({ bottom: 60 })
        .translate({ y: this.downY })
        .opacity(this.downOpacityValue)
        .width('93%')
        .height(this.isExpanded ? 200 : 50)
        .clip(false)
        .align(Alignment.TopStart)
        .animation({
          duration: this.isExpanded ? 100 : 300,
          curve: this.isExpanded ? curves.springMotion(0.5, 0.5) : 0
        })

      }.height('100%')
      .width('100%')
      .backgroundColor('#F0F5F6')
    }.onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack;
      if (context.navDestinationId) {
        this.pageId = context.navDestinationId;
        // 页面创建时注册自定义转场动画参数
        this.registerCallback();
      }
    })


    // .expandSafeArea([SafeAreaType.SYSTEM])

  }

  @Builder
  tabBuild(item: barItemBean, index: number) {
    Column({ space: 3 }) {
      Image($rawfile(index === this.selectedIndex ? item.imgSelected : item.imgNormol))
        .width(25)
        .height(25)
        .draggable(false)
        .objectFit(ImageFit.Cover)
      Text(item.name)
        .fontColor(index === this.selectedIndex ? Color.Black : Color.Gray)
        .fontSize(13)
    }.onClick(() => {

      if (index === 0 || index === 2) {
        this.currentIndex = index

      } else {
        this.allDown = true
        if (this.isExpanded) {
          this.isExpanded = false
        }
        this.downWithAnimation()
        this.hideWithAnimation()
        setTimeout(() => {
          let param: object = new Object()
          param['isManYou'] = true
          this.pageInfo.pushPath({ name: 'songPlayingPage', param: param })

        }, 100)
      }


    })
    .margin({ bottom: 10 })
  }
}


@Builder
export function MainPageBuilder(name: string, param: object) {
  MainPage()
}

