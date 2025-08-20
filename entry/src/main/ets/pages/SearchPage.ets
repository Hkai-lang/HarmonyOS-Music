import { songBean } from "../bean/songBean";
import { HttpUtils } from "../utils/HttpUtils";
import { SharePreferenceUtil } from "../utils/SharePreferenceUtil";

@Component
export struct SearchPage {
  pageInfo: NavPathStack = new NavPathStack()
  controller: TextInputController = new TextInputController();
  @State searchText: string = ''
  @StorageLink('searchTxArray') searchTxArray: string[] = []
  @State isEx: boolean = true
  @State isDelete: boolean = false
  @State line: number = 0
  @State isSearch: boolean = false //是否显示联想搜索标识
  @State searchList: songBean[] = []
  @State searchHistory: string[] = []
  @State gusFavList: string[] = ['跳楼机', '猜', '离开我的依赖', '红尘客栈', '大风吹', '程艾影'] //猜你喜欢
  @State bangDan: Array<string[]> = [
    ['恋人', '夏夜最后的烟火', '褪黑素', '我们的明天', '离开我的依赖', '空心', '唯一','TWICE','最渣男主角','其实','可乐','成都'],
    ['褪黑素', '离开我的依赖', '两 难', '寂寞寂寞不好', '爱情讯息', '于是', '唯一','恋人','罗生门','爱错','零距离的思念','我怀念的'],
    ['NIGHTKIDZ夜之子', '最渣男主角', '孔雀', 'NOT GOOD', 'Lost', '我发誓我要美丽', '猜','失控','离开我的依赖','开始懂了','你啊你，我的心','恋人'],
    ['褪黑素', '一半晚安', '褪黑素2.0', '大城小爱', '暗流', '萤火星球', 'Jasmine','安和桥','你','我们俩','猜不透','他不懂']]
  @StorageLink('likeList') likeList: songBean[] = []

  aboutToAppear(): void {
    this.searchTxArray = SharePreferenceUtil.getInstance().getArrayString('searchTxArray')
  }

  aboutToDisappear(): void {
    SharePreferenceUtil.getInstance().putArrayString('searchTxArray', this.searchTxArray)
  }

  searchSong() {
    HttpUtils.httpGetSong(`https://music.cenguigui.cn/?server=netease&type=search&id=${this.searchText}`)
      .then((res) => {
        if (res) {
          let data: songBean[] = JSON.parse(res) || new Object()
          for (let i = 0; i < data.length; i++) {
            if (data[i].name.startsWith(this.searchText) || data[i].artist.startsWith(this.searchText)) {
              this.searchList.push(data[i])
            }
          }
          this.searchList = this.searchList.slice(0, 9)
          this.isSearch = true
          this.searchHistory.push(this.searchText)
        } else {
          this.isSearch = false
        }


      })
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Image($rawfile('back.png'))
            .width(35)
            .height(35)
            .margin({ left: 10 })
            .draggable(false)
            .onClick(() => {
              this.pageInfo.pop()
              AppStorage.setOrCreate('isSongList', false)
            })


          Row() {
            Image($r('app.media.search'))
              .width(23)
              .height(23)
              .margin({ left: 10 })
              .draggable(false)

            TextInput({ text: this.searchText!!, placeholder: '输入歌曲名或歌手', controller: this.controller })
              .backgroundColor('#FEFEFF')
              .width('70%')
              .defaultFocus(true)
              .onChange((data) => {
                if (this.searchText == '') {
                  this.isSearch = false
                } else {
                  this.searchList = []
                  this.searchSong()
                }

              })
              .onSubmit((callBack) => {
                this.searchSong()
              })


          }.width('73%')
          .borderRadius(25)
          .backgroundColor('#FEFEFF')

          Text('搜索')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 10 })
            .onClick(() => {
              if (!this.searchTxArray.some(item => item === this.searchText)) {
                this.searchTxArray.push(this.searchText)
                AppStorage.set('searchTxArray', this.searchTxArray)
                SharePreferenceUtil.getInstance().putArrayString('searchTxArray', this.searchTxArray)
              }
              this.searchSong()

            })


        }.width('100%')
        .margin({ top: 50 })

        //默认搜索页面
        Column() {
          //搜索历史
          Column() {
            Row() {
              Text('搜索历史').fontWeight(FontWeight.Bold).fontSize(16)
                .width(0)
                .layoutWeight(1)
              Image($rawfile('shanchu.png'))
                .width(25)
                .height(25)
                .onClick(() => {
                  if (this.isDelete) {
                    this.isDelete = false
                  } else {
                    this.isDelete = true
                  }

                  if (!this.isEx) {
                    this.isEx = true
                  }

                })
            }

            Row() {
              Flex({ wrap: FlexWrap.Wrap, direction: FlexDirection.Row }) {
                ForEach(this.searchTxArray, (data: string, index: number) => {
                  Text(this.isDelete ? data + ' ×' : data)
                    .borderRadius(30)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontSize(14)
                    .margin(5)
                    .padding(5)
                    .backgroundColor('#FEFEFF')
                    .onClick(() => {
                      if (this.isDelete) {
                        this.searchTxArray.splice(index, 1)
                        SharePreferenceUtil.getInstance().putArrayString('searchTxArray', this.searchTxArray)
                      } else {
                        this.searchText = data
                      }
                    })
                })

                Image($rawfile('up_black.png'))
                  .width(25)
                  .height(25)
                  .margin(5)
                  .padding(5)
                  .borderRadius(30)
                  .backgroundColor('#FEFEFF')
                  .onClick(() => {
                    this.isEx = false
                  })
                  .visibility(this.isEx && this.searchTxArray.length > 3 ? Visibility.Visible : Visibility.None)

              }.width(this.isEx ? '100%' : '90%')
              .height(this.isEx ? 'auto' : 36)
              .clip(true)
              .onAreaChange((oldValue, newValue) => {
                const itemHeight = 36
                const finalHei: number = parseInt(newValue.height.toString(), 10);
                this.line = Math.ceil(finalHei / itemHeight)
              })

              Image($rawfile('down_black.png'))
                .width(25)
                .height(25)
                .margin(5)
                .padding(5)
                .borderRadius(30)
                .backgroundColor('#FEFEFF')
                .onClick(() => {
                  this.isEx = true
                })
                .visibility(!this.isEx && this.searchTxArray.length > 3 ? Visibility.Visible : Visibility.None)

            }.width('100%')
            .margin({ top: 10 })

          }.margin({ top: 20 })
          .width('90%')
          .visibility(this.searchTxArray.length == 0 ? Visibility.None : Visibility.Visible)

          //猜你喜欢
          Column() {
            Text('猜你喜欢').fontWeight(FontWeight.Bold).fontSize(16)
              .alignSelf(ItemAlign.Start)

            Grid() {
              ForEach(this.gusFavList, (txt: string, index: number) => {
                GridItem() {
                  Text(txt).fontSize(15)

                }.align(Alignment.Start)
              })
            }
            .columnsTemplate('1fr 1fr ')
            .rowsTemplate('1fr 1fr 1fr')
            .width('100%')
            .height(100)
            .margin({ top: 10 })

          }.margin({ top: 20 })
          .width('90%')


          //热搜榜
          List() {
            ForEach(this.bangDan, (array: string[], index: number) => {
              ListItem() {
                if (index === 0) {
                  this.bangDanItem(array, '热搜榜')
                } else if (index === 1) {
                  this.bangDanItem(array, '热歌榜')
                } else if (index === 2) {
                  this.bangDanItem(array, '飙升榜')
                } else if (index === 3) {
                  this.bangDanItem(array, '新歌榜')
                }
              }.borderRadius(5)
              .backgroundColor('#FEFEFF')
              .margin({ left: 15 })
              .width('65%')

            })

          }.listDirection(Axis.Horizontal)
          .width('100%')
          .margin({top:20})

        }.width('100%')
        .visibility(this.isSearch ? Visibility.None : Visibility.Visible)

        //联想搜索结果
        Column() {
          List({ space: 20 }) {
            if (this.searchHistory.some(item => item === this.searchText)) {
              this.searchItem(true)
            }
            ForEach(this.searchList, (song: songBean, index: number) => {
              ListItem() {
                if (this.likeList.some(item => item.id === song.id) && this.likeList) {
                  this.searchItem(false, song, true)
                } else {
                  this.searchItem(false, song)
                }
              }

            })
          }.scrollBar(BarState.Off)
          .divider({ strokeWidth: 1, color: Color.Gray })
          .margin({ bottom: 90 })

        }.margin({ top: 20 })
        .width('90%')
        .visibility(this.isSearch ? Visibility.Visible : Visibility.None)

      }.width('100%')
      .height('100%')
      .backgroundColor('#F0F5F6')

    }.onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack
    })
    .hideTitleBar(true)

  }

  @Builder
  searchItem(isHis: boolean, song?: songBean, isFav?: boolean) {
    Row() {
      Image($rawfile(isHis ? 'lishi.png' : 'search.png'))
        .width(15)
        .height(15)
      Text(isHis ? this.searchText : song!.name)
        .fontSize(18)
        .margin({ left: 5 })
      if (!isHis) {
        Text(song!.artist)
          .fontSize(18)
          .margin({ left: 5 })
        if (isFav) {
          Text('已收藏')
            .width(28)
            .height(15)
            .fontSize(8)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF3C3B')
            .borderRadius(2)
            .border({ width: 2, color: '#FF3C3B' })
            .margin({ left: 5 })
        }

      }

    }
  }

  @Builder
  bangDanItem(array: string[], title: string) {
    Column() {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bolder)
        .alignSelf(ItemAlign.Start)

      Row().width('100%').border({ width: 0.5, color: '#333437' }).margin({ top: 10 })
        .height(1)

      Column({ space: 10 }) {
        ForEach(array, (data: string, index: number) => {
          Row() {
            Text((index + 1).toString()).fontSize(15)
              .fontColor((index + 1) < 4 ? '#FE3C3B' : Color.Black)
              .fontWeight(FontWeight.Bolder)
              .width(20).height(20)

            Text(data).margin({ left: 5 }).width(0).layoutWeight(1)

            if ((index + 1) < 4) {
              Text('爆').width(15).height(15).backgroundColor('#FD393A')
                .fontColor('#FEFFFF').fontSize(12)
                .borderRadius(3)
                .textAlign(TextAlign.Center)
            }


          }.width('100%')
        })
      }.margin({ top: 10 })

    }.width('90%')
    .margin({ top: 10 })
  }
}

@Builder
export function SearchPageBuilder(name: string, param: object) {
  SearchPage()
}
