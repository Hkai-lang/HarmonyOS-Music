import { songBean } from "../bean/songBean";
import { CommonUtils } from "./CommonUtils";
import { SharePreferenceUtil } from "./SharePreferenceUtil";


//歌曲工具类
export class SongUtils {
  //收藏歌曲
  public static likeSong(songInfo: songBean, list: songBean[]) {
    if (list.some(song => song.id === songInfo.id)) {
      let index = list.findIndex(song => song.id === songInfo.id)
      list.splice(index, 1)
      CommonUtils.toastShow('已取消喜欢～')
    } else {
      list.push(songInfo)
      CommonUtils.toastShow('已添加到我的收藏～')
    }
    AppStorage.setOrCreate('likeList', list)
    SharePreferenceUtil.getInstance().putSongBeans('likeList', list)
  }

  //添加最近
  public static zuiJin(songInfo: songBean, list: songBean[]) {
    if (!list.some(song => song.id === songInfo.id)) {
      list.push(songInfo)
    }
    AppStorage.setOrCreate('nearList', list)
    SharePreferenceUtil.getInstance().putSongBeans('nearList', list)
  }
}