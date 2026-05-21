import { promptAction } from '@kit.ArkUI';
import { AppColors } from '../common/Theme';
import { ActionButton } from '../components/ActionButton';
import { HomeViewModel } from '../viewmodels/HomeViewModel';

@Entry
@Component
struct HomePage {
  private viewModel: HomeViewModel = new HomeViewModel();
  @State roomName: string = '';
  @State roomCode: string = '';

  private showTodoToast(action: string): void {
    promptAction.showToast({
      message: `${action}接口下一步接入`,
      duration: 1800
    });
  }

  build() {
    Column() {
      Column() {
        Text(this.viewModel.appName)
          .fontSize(34)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT)

        Text(this.viewModel.subtitle)
          .fontSize(15)
          .fontColor(AppColors.MUTED)
          .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding({ left: 24, right: 24, top: 40, bottom: 22 })

      Column({ space: 14 }) {
        TextInput({ placeholder: '课程或小组名称', text: this.roomName })
          .height(48)
          .fontSize(15)
          .backgroundColor(AppColors.SURFACE)
          .borderRadius(12)
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.roomName = value;
          })

        ActionButton({
          label: '创建传输房间',
          primary: true,
          onTap: () => {
            this.showTodoToast('创建房间');
          }
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 18, bottom: 18 })

      Column({ space: 14 }) {
        TextInput({ placeholder: '输入 6 位房间码', text: this.roomCode })
          .height(48)
          .fontSize(15)
          .backgroundColor(AppColors.SURFACE)
          .borderRadius(12)
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.roomCode = value.toUpperCase();
          })

        ActionButton({
          label: '加入房间',
          primary: false,
          onTap: () => {
            this.showTodoToast('加入房间');
          }
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 6, bottom: 18 })

      Column() {
        Text('MVP')
          .fontSize(13)
          .fontColor(AppColors.MUTED)

        Text('先打通服务器中转传输，之后再接入剪贴板和局域网直传。')
          .fontSize(14)
          .fontColor(AppColors.TEXT)
          .lineHeight(22)
          .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding({ left: 24, right: 24, top: 18 })

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.BACKGROUND)
  }
}

