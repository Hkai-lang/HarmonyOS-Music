export class songBean {
  id: number = 0
  album_id: number = 0
  name: string = '' //歌曲名字
  duration: number = 0
  cover: string = ''
  lang: string = ''
  listen_end: number = 0
  performer: string = '' //作者
  mp3_wav: string = ''
  style: string = ''
  src: string = ''
  url: string = ''
  pic: string = '' // 图片
  img: string = ''
  lrc: string = '' //歌词
  artist:string = ''
  alnum: Alnum = new Alnum()
  backgroundColor: ResourceColor = '';
  songDurationFinal:string = ''



}
/*

search 搜索作者\歌名
name 歌曲名
artist 歌手
url 链接
pic 封面
lrc 歌词
song 单曲
playlist 歌单
search 搜索
album 唱片*/

class Alnum {
  id: number = 0
  name: string = ''
  alias_name: string = ''
  sub_name: string = ''
  product_code: number = 0
  editor_code: number = 0
  bar_code: string = ''
  performer: string = ''
  version: string = ''
  link: string = ''
  main_version: number = 0
  album_desc: string = ''
  intro: string = ''
  issue_time: string = ''
  issue_state: number = 0
  issue_company: number = 0
  issue_area: number = 0
  copyright: number = 0
  money: string = ''
  graphy: string = ''
  style: string = ''
  lang: string = ''
  is_hot: number = 0
  sort_hot: number = 0
  audit: number = 0
  disc_count: number = 0
  cover: string = ''
  tag: string = ''
  created_at: string = ''
  updated_at: string = ''
  deleted_at: string = ''
}