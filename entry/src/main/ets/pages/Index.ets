import { HomePage, imgInfoBean } from "./HomePage";

import { songBean } from "../bean/songBean";

import { barItemBean } from "../bean/barItemBean";
import { AnimateCallback, CustomTransitionUtils } from "../utils/CustomTransitionUtils";
import { curves } from "@kit.ArkUI";
import { EventContanst } from "../utils/EventContanst";
import { CommonUtils } from "../utils/CommonUtils";


@Entry
@Component
struct Index {
  pageInfo: NavPathStack = new NavPathStack();
  @StorageLink('isSongList') isSongList: boolean = false

  aboutToAppear(): void {
    this.pageInfo.pushPath({ name: 'Main' })

  }

  build() {
    Navigation(this.pageInfo) {

    }
    .height('100%')
    .width('100%')
    .navBarWidth(0)
    .hideNavBar(true)
    .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
      // 首页不进行自定义动画
      if (from.index === -1 || to.index === -1) {
        return undefined;
      }
      let customAnimation: NavigationAnimatedTransition = {
        timeout: 2000,
        // 转场开始时系统调用该方法，并传入转场上下文代理对象
        transition: (transitionProxy: NavigationTransitionProxy) => {
          if (!from.navDestinationId || !to.navDestinationId) {
            return;
          }
          // 从封装类CustomTransition中根据子页面的序列获取对应的转场动画回调
          let fromParam: AnimateCallback = CustomTransitionUtils.getInstance().getAnimateParam(from.navDestinationId);
          let toParam: AnimateCallback = CustomTransitionUtils.getInstance().getAnimateParam(to.navDestinationId);
          // Push动画
          if (operation == NavigationOperation.PUSH) {
            if (fromParam.start && toParam.start) {
              // 设置Push转场的两个页面的动画起点
              fromParam.start(true, true);
              toParam.start(true, false);
            }

            animateTo({
              duration: 400, curve: Curve.Friction, onFinish: () => {
                // 动画结束后需要手动调用finishTransition，否则在timeout时间后由系统调用
                transitionProxy.finishTransition();
              }
            }, () => {
              if (fromParam.finish && toParam.finish) {
                // 设置Push转场的两个页面的动画终点
                fromParam.finish(true, true);
                toParam.finish(true, false);
              }

            })
          } else if (operation == NavigationOperation.POP) {
            // Pop动画
            if (fromParam.start && toParam.start) {
              // 设置Pop转场的两个页面的动画起点
              fromParam.start(false, true);
              toParam.start(false, false);
            }
            animateTo({
              duration: 450, curve: Curve.Friction, onFinish: () => {
                // 动画结束后需要手动调用finishTransition，否则在timeout时间后由系统调用
                transitionProxy.finishTransition();
                if (from.name === 'songPlayingPage' || from.name === 'geDanPage') {
                  if (!this.isSongList) {
                    CommonUtils.postEvent(EventContanst.showBar, '', 'allUp')
                  }else {
                    CommonUtils.postEvent(EventContanst.showBar,'','upOne')
                  }
                }
              }
            }, () => {
              if (fromParam.finish && toParam.finish) {
                // 设置Pop转场的两个页面的动画终点
                fromParam.finish(false, true);
                toParam.finish(false, false);
              }
            })
          } else {
            // Replace不做动画
          }
        }
      };
      return customAnimation;

    })
  }
}

@Builder
export function IndexBuilder(name: string, param: object) {
  Index()
}

