/**
 * IntroPage — first-run intro slides (Markor / View / Share / ToDo / Done).
 *
 * First-run slides with stable Next, Skip, and Done action keys.
 */
import router from '@ohos.router';
import { SK, ROUTE } from '../model/AppModel';

@Entry
@Component
struct IntroPage {
  @State slide: number = 0;
  private titles: string[] = ['Markor', 'View', 'Share', 'To-Do', 'Done'];
  private descs: string[] = [
    'Write down notes, manage tasks',
    'View your documents',
    'Share text into Markor',
    'Manage your tasks',
    'All set!',
  ];
  private icons: Resource[] = [
    $r('app.media.gs_markdown_black_24dp'),
    $r('app.media.ic_visibility_black_24dp'),
    $r('app.media.ic_share_black_24dp'),
    $r('app.media.ic_assignment_turned_in_black_24dp'),
    $r('app.media.ic_check_circle_24dp'),
  ];

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.End, alignItems: ItemAlign.Center }) {
        Text($r('app.string.skip')).fontSize(14).fontColor('#FFFFFF').padding(12).key('intro_skip')
          .onClick(() => { AppStorage.set<string>(SK.CUR_ROUTE, ROUTE.MAIN); router.replaceUrl({ url: ROUTE.MAIN }); })
      }.width('100%')

      Column() {
        Image(this.icons[this.slide]).width(120).height(120).fillColor('#FFFFFF')
        Text(this.titles[this.slide]).fontSize(28).fontColor('#FFFFFF').margin({ top: 24 }).fontWeight(FontWeight.Medium)
        Text(this.descs[this.slide]).fontSize(15).fontColor('#E0E0E0').margin({ top: 12, left: 32, right: 32 })
          .textAlign(TextAlign.Center)
      }.layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

      Row() {
        ForEach([0, 1, 2, 3, 4], (i: number) => {
          Column()
            .width(8).height(8).borderRadius(4)
            .backgroundColor(i === this.slide ? '#FFFFFF' : '#7E57C2')
            .margin({ left: 4, right: 4 })
        }, (i: number) => `dot_${i}`)
      }.width('100%').justifyContent(FlexAlign.Center).padding(16)

      Row() {
        Button(this.slide < 4 ? 'Next' : 'Done')
          .backgroundColor('#FFFFFF').fontColor('#5E35B1')
          .key(this.slide < 4 ? 'intro_next' : 'intro_done')
          .onClick(() => {
            if (this.slide < 4) { this.slide++; }
            else {
            }
          })
      }.width('100%').justifyContent(FlexAlign.Center).padding({ bottom: 32 })
    }.width('100%').height('100%').backgroundColor('#5E35B1')
  }
}
