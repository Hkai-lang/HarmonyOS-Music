import dataPreferences from '@ohos.data.preferences';
import { BusinessError } from '@ohos.base';
import { songBean } from '../bean/songBean';

const TAG: string = "SharePreferenceUtil"

export class SharePreferenceUtil {
  private songDataStore?: dataPreferences.Preferences | null = null;
  private isInitFinished: boolean = false;
  private static instance: SharePreferenceUtil;

  public static getInstance(): SharePreferenceUtil {
    if (!SharePreferenceUtil.instance) {
      SharePreferenceUtil.instance = new SharePreferenceUtil();
    }
    return SharePreferenceUtil.instance;
  }


  //初始化
  public createPreferences(context?: Context, PREFERENCES_NAME?: string) {
    try {
      if (this.isInitFinished) {
        return
      }
      let options: dataPreferences.Options = { name: PREFERENCES_NAME! };
      this.songDataStore = dataPreferences.getPreferencesSync(context, options);
      this.isInitFinished = true
    } catch (err) {
      let code = (err as BusinessError).code;
      let message = (err as BusinessError).message;
      console.error(TAG, "Failed to get preferences. code =" + code + ", message =" + message);
    }
  }

  public putString(key: string, value: string) {
    if (this.isInitFinished) {
      this.songDataStore?.putSync(key, value)
      this.saveSongData();
    } else {
      console.error(TAG, 'Preference is not initialized. ');
    }
  }

  //同步
  public getString(key: string): string {
    if (this.isInitFinished) {
      let value = ""
      try {
        if (this.songDataStore == undefined) {
          console.error(TAG, 'this.songDataStore is undefined');
          return ""
        }
        let data: dataPreferences.ValueType = this.songDataStore.getSync(key, '');
        return data as string
      } catch (err) {
        value = 'fail'
      }
      return value
    } else {
      console.error(TAG, 'Preference is not initialized. ');
      return ""
    }
  }

  public putBoolean(key: string, value: boolean) {
    if (this.isInitFinished) {
      this.songDataStore?.putSync(key, value)
      this.saveSongData();
    } else {
      console.error(TAG, 'Preference is not initialized. ');
    }
  }

  public getBoolean(key: string): boolean {
    if (this.isInitFinished) {
      try {
        if (this.songDataStore == undefined) {
          console.error(TAG, 'this.songDataStore is undefined');
          return false
        }
        let data: dataPreferences.ValueType = this.songDataStore.getSync(key, false)
        return data as boolean
      } catch (err) {
        console.error(TAG, 'Preference is not initialized. ');
      }
      return false
    } else {
      console.error(TAG, 'Preference is not initialized. ');
      return false
    }
  }

  public putNumber(key: string, value: number) {
    if (this.isInitFinished) {
      this.songDataStore?.putSync(key, value)
      this.saveSongData();
    } else {
      console.error(TAG, 'Preference is not initialized. ');
    }
  }

  public getNumber(key: string): number {
    if (this.isInitFinished) {
      try {
        if (this.songDataStore == undefined) {
          console.error(TAG, 'this.songDataStore is undefined');
          return 0
        }
        let data: dataPreferences.ValueType = this.songDataStore.getSync(key, 0)
        return data as number
      } catch (err) {
      }
      return 0
    } else {
      console.error(TAG, 'Preference is not initialized. ');
      return 0
    }
  }


  public putArrayNumber(key: string, value: Array<number>) {
    if (this.isInitFinished) {
      this.songDataStore?.putSync(key, value)
      this.saveSongData();
    } else {
      console.error(TAG, 'Preference is not initialized. ');
    }
  }

  public getArrayNumber(key: string): Array<number> {
    if (this.isInitFinished) {
      try {
        if (this.songDataStore == undefined) {
          console.error(TAG, 'this.getArrayNumber is undefined');
          return []
        }
        let data: dataPreferences.ValueType = this.songDataStore?.getSync(key, [])
        return data as Array<number>
      } catch (err) {
      }
      return []
    } else {
      console.error(TAG, 'Preference is not initialized. ');
      return []
    }
  }

  public putArrayString(key: string, value: Array<string>) {
    if (this.isInitFinished) {
      this.songDataStore?.putSync(key, value)
      this.saveSongData();
    } else {
      console.error(TAG, 'Preference is not initialized. ');
    }
  }

  public getArrayString(key: string): Array<string> {
    if (this.isInitFinished) {
      try {
        if (this.songDataStore == undefined) {
          console.error(TAG, 'this.getArrayString is undefined');
          return []
        }
        let data: dataPreferences.ValueType = this.songDataStore?.getSync(key, [])
        return data as Array<string>
      } catch (err) {
      }
      return []
    } else {
      console.error(TAG, 'Preference is not initialized. ');
      return []
    }
  }


  //删除数据
  async deleteData(key: string) {
    if (this.isInitFinished) {
      this.songDataStore?.deleteSync(key)
      this.saveSongData();
    } else {
      console.error(TAG, 'Preference is not initialized. ');
    }
  }

  public saveSongData() {
    this.songDataStore?.flush();
  }



  // 新增方法到 SharePreferenceUtil 类中

  /**
   * 存储对象（自动转为JSON字符串）
   * @param key 存储键
   * @param value 要存储的对象
   */
  public putObject<T>(key: string, value: T): void {
    if (this.isInitFinished) {
      try {
        const jsonString = JSON.stringify(value);
        this.songDataStore?.putSync(key, jsonString);
        this.saveSongData();
      } catch (err) {
        console.error(TAG, `Failed to put object: ${(err as BusinessError).message}`);
      }
    } else {
      console.error(TAG, 'Preference is not initialized.');
    }
  }

  /**
   * 获取存储的对象
   * @param key 存储键
   * @param defaultValue 默认值
   * @returns 解析后的对象或默认值
   */
  public getObject<T>(key: string, defaultValue: T): T {
    if (this.isInitFinished) {
      try {
        if (this.songDataStore == undefined) {
          console.error(TAG, 'this.songDataStore is undefined');
          return defaultValue;
        }
        const jsonString = this.songDataStore.getSync(key, '') as string;
        return jsonString ? JSON.parse(jsonString) as T : defaultValue;
      } catch (err) {
        console.error(TAG, `Failed to get object: ${(err as BusinessError).message}`);
        return defaultValue;
      }
    } else {
      console.error(TAG, 'Preference is not initialized.');
      return defaultValue;
    }
  }

  /**
   * 存储对象数组（自动转为JSON字符串）
   * @param key 存储键
   * @param value 要存储的对象数组
   */
  public putObjectArray<T>(key: string, value: Array<T>): void {
    this.putObject(key, value);
  }

  /**
   * 获取存储的对象数组
   * @param key 存储键
   * @param defaultValue 默认数组
   * @returns 解析后的对象数组或默认数组
   */
  public getObjectArray<T>(key: string, defaultValue: Array<T>): Array<T> {
    return this.getObject<Array<T>>(key, defaultValue);
  }

  /**
   * 存储SongBean数组
   * @param key 存储键
   * @param songs 歌曲数组
   */
  public putSongBeans(key: string, songs: Array<songBean>): void {
    this.putObjectArray<songBean>(key, songs);

  }

  /**
   * 获取SongBean数组
   * @param key 存储键
   * @returns 歌曲数组，若无则返回空数组
   */
  public getSongBeans(key: string): Array<songBean> {
    return this.getObjectArray<songBean>(key, []);
  }

}




// export default new SharePreferenceUtil();