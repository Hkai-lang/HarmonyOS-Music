
//防抖工具
export class DebounceSingletonUtil {
  private static instance: DebounceSingletonUtil;
  private static methodsMap: Map<string, number> = new Map();

  private constructor() {
  }

  public static getInstance(): DebounceSingletonUtil {
    if (!DebounceSingletonUtil.instance) {
      DebounceSingletonUtil.instance = new DebounceSingletonUtil();
    }
    return DebounceSingletonUtil.instance;
  }

  public isDebounced(methodName: string, milliseconds: number): boolean {
    const now = Date.now();
    const lastExecutionTime = DebounceSingletonUtil.methodsMap.get(methodName);

    if (lastExecutionTime && (now - lastExecutionTime) < milliseconds) {
      console.info(`${methodName}方法在指定时间${milliseconds}内已执行过`)
      return true; // 方法在指定时间内已执行过
    } else {
      DebounceSingletonUtil.methodsMap.set(methodName, now);
      return false; // 方法在指定时间内未执行过
    }
  }
}

