/**
 * PermissionPage — StoragePermissionActivity gate.
 *
 * Mirrors Android StoragePermissionActivity. spa_yes / spa_exit keys per labels.
 */
import router from '@ohos.router';
import { SK, ROUTE } from '../model/AppModel';

@Entry
@Component
struct PermissionPage {
  build() {
    Column() {
      Column() {
        Image($r('app.media.ic_folder_white_24dp')).width(96).height(96).fillColor('#1976D2')
        Text($r('app.string.storage_permission_required')).fontSize(16).fontColor('#212121')
          .margin({ top: 24, left: 24, right: 24 }).textAlign(TextAlign.Center)
      }.layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

      Row() {
        Button('OK').backgroundColor('#1976D2').fontColor('#FFFFFF').key('spa_yes')
          .onClick(() => {
            AppStorage.setOrCreate<string>(SK.CUR_ROUTE, ROUTE.MAIN);
            router.replaceUrl({ url: ROUTE.MAIN });
          })
        Button('Exit').backgroundColor('#FFFFFF').fontColor('#1976D2').key('spa_exit').margin({ left: 12 })
          .onClick(() => {})
      }.width('100%').justifyContent(FlexAlign.Center).padding({ bottom: 48 })
    }.width('100%').height('100%').backgroundColor('#FAFAFA')
  }
}
