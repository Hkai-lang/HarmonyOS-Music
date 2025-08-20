import emitter from '@ohos.events.emitter';
import { promptAction, window } from '@kit.ArkUI';
import { songBean } from '../bean/songBean';

type EventCallback = (result: Record<string, string>) => void

/**
 * 公共工具类
 */
export class CommonUtils {

  /**
   * 发送事件
   *
   * @param eventId 事件编号
   * @param status  状态
   * @param msg     消息
   */
  public static postEvent(eventId: number, status?: string, message?: string) {
    if (status === undefined) {
      status = ''
    }
    if (message === undefined) {
      message = ''
    }
    let innerEvent: emitter.InnerEvent = { eventId: eventId }
    let eventData: emitter.EventData = {
      data: {
        'status': status,
        'message': message
      }
    }
    emitter.emit(innerEvent, eventData)
  }

  /**
   * 接受事件
   *
   * @param eventId 事件编号
   */
  public static handleEvent(eventId: number, callback: EventCallback) {
    let innerEvent: emitter.InnerEvent = { eventId: eventId }
    emitter.on(innerEvent, data => {
      let status: string = ''
      let message: string = ''
      if (data.data != null) {
        status = data.data.status
        message = data.data.message
      }
      let result: Record<string, string> = {
        'status': status,
        'message': message
      }
      callback(result)
    })
  }

  // 获取窗口对象后设置状态栏颜色
  public static async setStatusBarColor(color: string, context: Context) {
    try {
      let windowClass = await window.getLastWindow(context);
      windowClass.setWindowSystemBarProperties({
        statusBarColor: color,
        statusBarContentColor: '#000000' // 状态栏文字/图标颜色(白色)
      });
    } catch (error) {
      console.error('Failed to set status bar color. Cause: ' + error);
    }
  }

  //毫秒转成HH:MM:SS格式
  public static convertMillisecondsToTime(milliseconds: number): string {
    const totalSeconds = Math.floor(milliseconds / 1000); // 先将毫秒转换为秒
    const hours = Math.floor(totalSeconds / 3600).toString().padStart(2, '0')
    const minutes = Math.floor((totalSeconds % 3600) / 60).toString().padStart(2, '0')
    const seconds = (totalSeconds % 60).toString().padStart(2, '0');
    const ms = (milliseconds % 1000).toString().padStart(3, '0')
    if (hours === '00') {
      return `${minutes}:${seconds}`;
    } else {
      return `${hours}:${minutes}:${seconds}`;
    }
  }

  public static timeToMilliseconds(timeStr: string): number {
    const timeParts = timeStr.split(':'); // 分割分钟和秒
    const minutes = timeParts[0]; // 取分钟部分
    const secondsPart = timeParts[1]; // 取秒部分

    const secondsParts = secondsPart.split('.'); // 分割秒和毫秒
    const sec = secondsParts[0]; // 取秒
    const ms = secondsParts[1]; // 取毫秒
    return (
      parseInt(minutes) * 60 * 1000 +
        parseInt(sec) * 1000 +
      parseInt(ms.padEnd(3, '0')) // 确保毫秒是 3 位数
    );
  }

  //toast
  public static toastShow(message: string, duration?: number, bottom?: number) {
    promptAction.openToast({
      message: message,
      duration: duration ? duration : 500, //时长
      bottom: bottom ? bottom : 300  //距离底部
    })
  }
}