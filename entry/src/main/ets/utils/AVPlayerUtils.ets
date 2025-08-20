import { media } from '@kit.MediaKit'
import { audio } from '@kit.AudioKit'
import { Callback } from '@ohos.base';
import { CommonUtils } from './CommonUtils';
import { EventContanst } from './EventContanst';
import { songBean } from '../bean/songBean';
import { SharePreferenceUtil } from './SharePreferenceUtil';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { DebounceSingletonUtil } from './DebounceSingletonUtil';
import { getInternetImgColor } from './ImageUtils';

export class AVPlayerUtils {
  private static instance: AVPlayerUtils;
  private avPlayer: media.AVPlayer | undefined = undefined;
  private isPlaying: boolean = false;
  private songDuration: number = 0
  private songTime: number = 0
  private lastSong: string = ''
  private isInitializing: boolean = false; // 添加初始化状态锁
  private pendingUrl: string | null = null; // 待处理的URL

  private constructor() {
  }

  // 获取单例实例
  public static getInstance(): AVPlayerUtils {
    if (!AVPlayerUtils.instance) {
      AVPlayerUtils.instance = new AVPlayerUtils();
    }
    return AVPlayerUtils.instance;
  }

  // 初始化 AVPlayer 实例
  async initPlayer(url: string): Promise<void> {

    try {
      this.avPlayer = await media.createAVPlayer();
      this.setAVPlayerCallback(this.avPlayer);
      if (url) {
        this.avPlayer.url = url;
      }
    } catch (error) {
      console.error('初始化播放器失败:', error);
      throw new Error(`初始化播放器失败: ${error}`);
    }


  }

  // 设置 AVPlayer 的状态回调
  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          try {
            await avPlayer.release();
            hilog.debug(1, 'wyp', 'reset销毁')
          } catch (error) {
            console.error('释放播放器失败:', error);
          }
          // console.info('AVPlayer state idle called.');
          // avPlayer.release(); // 调用release接口销毁实例对象
          // hilog.debug(1, 'wyp', 'reset销毁')
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          console.info('AVPlayer state initialized called.');
          avPlayer.audioRendererInfo = {
            usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
            rendererFlags: 0
          }
          avPlayer.prepare();
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          console.info('AVPlayer state prepared called.');
          this.isPlaying = false
          AppStorage.setOrCreate('isPLaying', false)
          avPlayer.play(); // 调用播放接口开始播放
          break;
        case 'playing': // play成功调用后触发该状态机上报
          this.isPlaying = true
          CommonUtils.postEvent(EventContanst.playSate)
          // this.imgPlay = $r('app.media.pause')
          console.info('AVPlayer state playing called.');
          hilog.debug(1, 'wyp', '播放')

          break;
        case 'paused': // pause成功调用后触发该状态机上报
          this.isPlaying = false
          CommonUtils.postEvent(EventContanst.playSate)
          hilog.debug(1, 'wyp', '暂停')

          // this.imgPlay = $r('app.media.bofang')
          console.info('AVPlayer state paused called.');

          break;
        case 'completed': // 播放结束后触发该状态机上报
          console.info('AVPlayer state completed called.');
          // avPlayer.stop(); //调用播放结束接口
          CommonUtils.postEvent(EventContanst.isFinish)
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          console.info('AVPlayer state stopped called.');
          avPlayer.reset(); // 调用reset接口初始化avplayer状态
          break;
        case 'released':
          console.info('AVPlayer state released called.');
          break;
        default:
          console.info('AVPlayer state unknown called.');
          break;
      }
    })
    //监听进度条长度，刷新资源时长。
    avPlayer.on('durationUpdate', (duration: number) => {

      // AppStorage.setOrCreate('songDuration',duration)
      // AppStorage.setOrCreate('songDurationFinal',CommonUtils.convertMillisecondsToTime(duration))
      let song: songBean = JSON.parse(SharePreferenceUtil.getInstance().getString('lastSong'))
      song.duration = duration
      song.songDurationFinal = CommonUtils.convertMillisecondsToTime(duration)
      SharePreferenceUtil.getInstance().putString('lastSong', JSON.stringify(song))

      let nowSong: songBean | undefined = AppStorage.get('nowSong')
      if (nowSong) {
        nowSong.duration = duration
        nowSong.songDurationFinal = CommonUtils.convertMillisecondsToTime(duration)
        AppStorage.setOrCreate('nowSong', nowSong)
      }


      // this.songDuration = duration
      console.info('durationUpdate called,new duration is :' + duration)
    })
    //监听进度条当前位置，刷新当前时间。
    avPlayer.on('timeUpdate', (time: number) => {
      AppStorage.setOrCreate('songPlayingTime', time)
      AppStorage.setOrCreate('songCurrentTime', CommonUtils.convertMillisecondsToTime(time))
      // this.songTime = time
      console.info('timeUpdate called,and new time is :' + time)
    })
    //监听seek()请求完成情况。
    // 当使用seek()跳转到指定播放位置后，如果seek操作成功，将上报该事件
    avPlayer.on('seekDone', (duration: number) => {
      // this.isPlaying = true
      CommonUtils.postEvent(EventContanst.songWords, '', 'seek')
      console.info('durationUpdate called,new seekDone is :' + duration)

    })


  }

  // 播放音频
  async play(url: string): Promise<void> {
    // 如果正在初始化，保存URL稍后处理
    if (this.isInitializing) {
      this.pendingUrl = url;
      return;
    }

    // 相同歌曲处理
    if (this.lastSong === url) {
      if (this.isPlaying) {
        await this.pause();
      } else {
        await this.resume();
      }
      return;
    }

    // 不同歌曲处理
    this.isInitializing = true;
    this.lastSong = url;

    try {
      // 先释放现有播放器
      if (this.avPlayer) {
        await this.reset();
        this.release();
      }

      // 初始化新播放器
      await this.initPlayer(url);
    } catch (error) {
      console.error('播放器初始化失败:', error);
    } finally {
      this.isInitializing = false;

      // 检查是否有待处理的URL
      if (this.pendingUrl && this.pendingUrl !== url) {
        const nextUrl = this.pendingUrl;
        this.pendingUrl = null;
        await this.play(nextUrl);
      }
    }

  }

  // 暂停音频
  async pause(): Promise<void> {
    await this.avPlayer?.pause();
  }

  // 切换音频
  async reset(): Promise<void> {
    if (!this.avPlayer) return;

    try {
      // 移除所有事件监听器，避免内存泄漏
      this.avPlayer.off('stateChange');
      this.avPlayer.off('durationUpdate');
      this.avPlayer.off('timeUpdate');
      this.avPlayer.off('seekDone');

      await this.avPlayer.reset();
    } catch (error) {
      console.error('重置播放器失败:', error)
      throw new Error(`重置播放器失败: ${error}`)
    }
    // await this.avPlayer?.reset();
  }

  // 恢复播放
  async resume(): Promise<void> {
    await this.avPlayer?.play();
  }

  // 停止播放
  async stop(): Promise<void> {
    await this.avPlayer?.stop();
  }

  // 获取当前播放状态
  public getPlayingState(): boolean {
    return this.isPlaying;
  }

  // 获取当前歌曲时长
  public getPlayingDuration(): number {
    return this.songDuration;
  }

  // 获取当前播放进度
  public getPlayingTime(): number {
    return this.songTime;
  }

  // 跳转进度
  async seek(time: number): Promise<void> {
    await this.avPlayer?.seek(time)
  }


  // 释放播放器资源
  release() {
    this.avPlayer?.release();
    this.avPlayer = undefined;
  }


  qieGe(isNext: boolean ,geDanSongArray:songBean[],nowSong:songBean,isDebounce:boolean) {
    if (geDanSongArray.length > 0) {
      if (DebounceSingletonUtil.getInstance().isDebounced('防抖', 500) && isDebounce) {
        CommonUtils.toastShow('点击太快了哦～')
        return
      }else {
        let index = geDanSongArray.findIndex(song => song.id === nowSong.id)
        if (isNext) {
          if (index === geDanSongArray.length - 1) {
            nowSong = geDanSongArray[0]

          } else {
            nowSong = geDanSongArray[index+1]
          }
        } else {
          if (index === 0) {
            nowSong = geDanSongArray[geDanSongArray.length-1]
          } else {
            nowSong = geDanSongArray[index-1]
          }
        }

        getInternetImgColor(nowSong.pic).then((color) => {
          nowSong.backgroundColor = color
          AppStorage.setOrCreate('nowSong',nowSong)
          CommonUtils.postEvent(EventContanst.songWords, '', 'next')
          AVPlayerUtils.getInstance().play(nowSong.url)
        })
      }


    } else {
      CommonUtils.toastShow('没有其他歌了哦～', 500, 300)
    }
  }


  // 更新歌词显示，根据当前时间匹配歌词
  updateCurrentLyric(wordMap: Map<string, string>,songPlayingTime: number,lyricItemHeight: number) {
    let count = 0
    if (wordMap) {
        wordMap.forEach((key: string, value: string) => {
        let currentTime = CommonUtils.convertMillisecondsToTime(songPlayingTime)
        if (currentTime === value.slice(0, 5)) {
           let currentLyricIndex = count
          // 计算滚动位置，使当前歌词不在最上方（例如：保留前 2 行）
          const offsetLines = 2; // 希望保留的已播放行数
          const yOffset = Math.max(0, (currentLyricIndex - offsetLines) * lyricItemHeight);

          let yOffsetSmall = currentLyricIndex * lyricItemHeight;
          AppStorage.setOrCreate('updateSongWords', yOffsetSmall)
          AppStorage.setOrCreate('yOffset', yOffset)
          hilog.debug(1,'wyp111','更新歌词yOffset : '+yOffset)
          AppStorage.setOrCreate('currentLyricIndex', currentLyricIndex)
          CommonUtils.postEvent(EventContanst.songWords, '', 'update')
          // this.listController.scrollTo({ xOffset: 0, yOffset: yOffset, animation: true }); // smooth 表示平滑滚动
        }
        count++
      })
    }
  }


}