/**
 * SettingsPage — Settings root (preference categories).
 *
 * Settings root with stable category keys. Sub-categories navigate to
 * SettingsSubPage.
 */
import router from '@ohos.router';
import { SK, ROUTE } from '../model/AppModel';

@Entry
@Component
struct SettingsPage {
  @Builder row(title: string, summary: string, key: string, icon: Resource, sub: string = '') {
    Row() {
      Image(icon).width(24).height(24).fillColor('#757575').margin({ right: 16 })
      Column() {
        Text(title).fontSize(15).fontColor('#212121')
        if (summary.length > 0) {
          Text(summary).fontSize(12).fontColor('#757575').margin({ top: 2 })
        }
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      // D2: Android reference root preference rows have NO trailing chevron — removed.
    }.width('100%').padding({ left: 16, right: 16, top: 14, bottom: 14 })
     .key(key)
     .onClick(() => {
       if (sub.length > 0) { router.pushUrl({ url: ROUTE.SETTINGS_SUB, params: { name: sub } }); }
     })
  }

  @Builder header(text: string | Resource) {
    Text(text).fontSize(13).fontColor('#1976D2').fontWeight(FontWeight.Medium)
      .width('100%').padding({ left: 16, top: 16, bottom: 8 })
  }

  build() {
    Column() {
      // Appbar
      Row() {
        Image($r('app.media.ic_arrow_back_white_24dp')).width(28).height(28).fillColor('#FFFFFF')
          .margin({ left: 8, right: 8 }).onClick(() => router.back())
        Text($r('app.string.settings')).fontSize(20).fontColor('#FFFFFF').layoutWeight(1)
      }.width('100%').height(56).backgroundColor('#1E2135').alignItems(VerticalAlign.Center)
       .key('settings_root_title')

      Scroll() {
        Column() {
          // General
          this.header('General')
          this.row('Files and folders', '', 'pref_category_general_files', $r('app.media.baseline_snippet_folder_24'), 'general')
          this.row('Other', '', 'pref_category_general_other', $r('app.media.ic_settings_black_24dp'), 'general')
          this.row('Miscellaneous', '', 'pref_category_general_miscellaneous', $r('app.media.ic_settings_black_24dp'), 'general')

          // Edit Mode
          this.header('Edit Mode')
          this.row('Editor Settings', '', 'pref_category_editor', $r('app.media.ic_edit_black_24dp'), 'editor')

          // View Mode
          this.header('View Mode')
          this.row('Display converted markup', '', 'pref_category_view_mode', $r('app.media.ic_visibility_black_24dp'), 'view')

          // Format
          this.header('Format')
          this.row('Markdown', '', 'pref_category_format_markdown', $r('app.media.ic_format_bold_black_24dp'), 'format/Markdown')
          this.row('todo.txt', '', 'pref_category_format_todo', $r('app.media.ic_baseline_file_copy_24'), 'format/To-Do')
          this.row('Wikitext / Zim', '', 'pref_category_format_wikitext', $r('app.media.ic_file_gray_24dp'), 'format/Wikitext / Zim')
          this.row('Plain Text', '', 'pref_category_format_plaintext', $r('app.media.ic_file_gray_24dp'), 'format/Plain Text')
        }.width('100%').backgroundColor('#FFFFFF')
      }.layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#FFFFFF')
  }
}
