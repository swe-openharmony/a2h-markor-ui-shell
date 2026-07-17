import router from '@ohos.router';
import { ROUTE } from '../model/AppModel';

@Entry
@Component
struct Index {
  aboutToAppear() {
    router.replaceUrl({ url: ROUTE.MAIN });
  }

  build() {
    Column() {
      Text('Markor').fontSize(24).fontColor('#212121')
    }.width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
  }
}
