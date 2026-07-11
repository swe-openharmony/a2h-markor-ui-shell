/**
 * ShareIntoPage — Share-into editor.
 *
 * Share editor on top, action list below (QuickNote / To-Do / Select /
 * Search / Recent), plus a stable format-link checkbox key.
 */
import router from '@ohos.router';

@Entry
@Component
struct ShareIntoPage {
  @State private sharedText: string = '';
  @State private formatLink: boolean = false;

  @Builder attachRow(title: string, key: string) {
    Row() {
      Image($r('app.media.ic_attach_file_black_24dp')).width(24).height(24).fillColor('#616161')
      Text(title).fontSize(15).margin({ left: 12 })
    }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).key(key)
  }

  build() {
    Column() {
      // Appbar
      Row() {
        Image($r('app.media.ic_arrow_back_white_24dp')).width(28).height(28).fillColor('#FFFFFF')
          .margin({ left: 8, right: 8 }).onClick(() => router.back())
        Text($r('app.string.share_into')).fontSize(20).fontColor('#FFFFFF').layoutWeight(1)
      }.width('100%').height(56).backgroundColor('#1E2135').alignItems(VerticalAlign.Center)

      // Editor (share-into variant)
      TextArea({ text: this.sharedText })
        .width('100%').layoutWeight(1).fontSize(15)
        .id('document__fragment__share_into__highlighting_editor')
        .onChange((v: string) => { this.sharedText = v; })

      // Format link checkbox
      Row() {
        Checkbox().select(this.formatLink).key('share_into_format_link_cb')
          .onChange((v: boolean) => { this.formatLink = v; })
        Text('Format link').fontSize(14).margin({ left: 8 })
      }.width('100%').padding(12)

      // Attach list
      Text($r('app.string.attach')).fontSize(13).fontColor('#1976D2').width('100%').padding({ left: 16, top: 8, bottom: 8 })
      this.attachRow('QuickNote', 'pref_key__share_into__quicknote')
      this.attachRow('To-Do', 'pref_key__share_into__todo')
      this.attachRow('notes.md', 'pref_key__share_into__most_recent_document')
      this.attachRow('Select', 'pref_key__select_create_document')
      this.attachRow('Search', 'pref_key__search_for_target')
      this.attachRow('Clipboard', 'pref_key__share_into__clipboard')
    }.width('100%').height('100%').backgroundColor('#FFFFFF')
  }
}
