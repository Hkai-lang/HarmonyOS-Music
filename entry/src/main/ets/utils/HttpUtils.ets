/**
 * 网络请求api工具类
 */
import { rcp } from "@kit.RemoteCommunicationKit";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { http } from "@kit.NetworkKit";

export class HttpUtils {
  /**
   * 最新音乐排行榜top100
   * @param url
   * @returns
   */
  public static httpGetSong(url: string): Promise<string> {
    // return new Promise((res,rej)=>{
    //   http.createHttp().request(url).then(result => {
    //     let data: string = JSON.stringify(result)
    //     res(data)
    //   }).catch((err: BusinessError) => {
    //     console.debug(`报错：${err.code} ${err.data}`)
    //   })
    // })
    return new Promise((res,ref)=>{
      const session = rcp.createSession()
      session.get(url).then((response: rcp.Response) => {
        let data: string = JSON.stringify(response)
        res(data)
        hilog.debug(1, "数据", JSON.stringify(response))
      }).catch((err: BusinessError) => {
        console.debug(`报错：${err.code} ${err.data}`)
      })
    })
  }
  public static GetSongWords(url: string): Promise<string> {
    return new Promise((res,rej)=>{
      http.createHttp().request(url).then(result => {
        let data: string = JSON.stringify(result)
        res(data)
      }).catch((err: BusinessError) => {
        console.debug(`报错：${err.code} ${err.data}`)
      })
    })

  }

/**
 * 获取指定歌曲
 * @param url
 */
  public static httpGetSongKey(url:string){
    const session = rcp.createSession()
    session.get(url).then((response: rcp.Response) => {
      let res: string = JSON.stringify(response)
      let data: object = JSON.parse(res) || new Object()
      hilog.debug(1, "数据", JSON.stringify(response))
    }).catch((err: BusinessError) => {
      console.debug(`获取歌曲地址报错：${err.code} ${err.data}`)
    })
  }
  /**
   * 获取歌曲token
   * @param url
   */
  public static httpGetSongToken(url:string){
    const session = rcp.createSession()
    session.get(url).then((response: rcp.Response) => {
      let res: string = JSON.stringify(response)
      let data: object = JSON.parse(res) || new Object()
      hilog.debug(1, "获取歌曲token", JSON.stringify(response))
    }).catch((err: BusinessError) => {
      console.debug(`获取歌曲地址报错：${err.code} ${err.data}`)
    })
  }


}