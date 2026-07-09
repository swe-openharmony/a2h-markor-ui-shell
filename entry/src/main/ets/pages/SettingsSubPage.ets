/**
 * SettingsSubPage — generic settings sub-screen.
 *
 * Hosts General / Editor / View / Format categories based on router param
 * `name`. Component keys cover the settings and format preferences.
 */
import router from '@ohos.router';
import { ROUTE } from '../model/AppModel';

@Entry
@Component
struct SettingsSubPage {
  @State name: string = 'general';

  aboutToAppear() {
    const p = router.getParams() as Record<string, string>;
    if (p && p.name) { this.name = p.name; }
  }

  @Builder row(title: string, summary: string, key: string) {
    Row() {
      Column() {
        Text(title).fontSize(15).fontColor('#212121')
        if (summary.length > 0) {
          Text(summary).fontSize(12).fontColor('#757575').margin({ top: 2 })
        }
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
    }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).key(key)
  }

  @Builder switchRow(title: string, summary: string, key: string, val: boolean) {
    Row() {
      Column() {
        Text(title).fontSize(15).fontColor('#212121')
        if (summary.length > 0) {
          Text(summary).fontSize(12).fontColor('#757575').margin({ top: 2 })
        }
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      Toggle({ type: ToggleType.Switch, isOn: val }).key(key)
    }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })
  }

  @Builder header(text: string) {
    Text(text).fontSize(13).fontColor('#1976D2').fontWeight(FontWeight.Medium)
      .width('100%').padding({ left: 16, top: 16, bottom: 8 })
  }

  @Builder general() {
    Column() {
      this.header('Save location')
      this.row('Notebook', 'Documents/markor', 'pref_key__notebook_directory')
      this.row('QuickNote', 'Documents/markor/QuickNote.md', 'pref_key__quicknote_filepath')
      this.row('To-Do', 'Documents/markor/todo.txt', 'pref_key__todo_filepath')
      this.header($r('app.string.miscellaneous').toString())
      this.row('App start tab', 'Notebook', 'pref_key__app_start_tab_v2')
      this.row('File description format', '', 'pref_key__file_description_format')
      this.row('Share into - Format', '', 'pref_key__share_into_format')
      this.row('Theme', 'system', 'pref_key__app_theme')
      this.row('Language', 'System', 'pref_key__language')
      this.row('Basic color scheme - Solarized', '', 'pref_key__basic_color_scheme_solarized')
      this.row('Set encryption password', '', 'pref_key__set_encryption_password')
    }.width('100%')
  }

  @Builder editor() {
    Column() {
      this.header($r('app.string.editor').toString())
      this.switchRow('Syntax Highlighting', 'Highlight entered text', 'pref_key__is_highlighting_activated', true)
      this.switchRow('Wrap Words', 'Soft break if not fit', 'pref_key__editor_enable_line_breaking', true)
      this.switchRow('Line Numbers', '', 'pref_key__enable_line_numbers', false)
      this.row('Font Size', '15', 'pref_key__editor_font_size')
      this.row('Line Spacing', '100%', 'pref_key__editor_line_spacing')
      this.switchRow('Disable spelling underline', '', 'pref_key__editor_disable_spelling_red_underline', false)
      this.switchRow('Use monospace for code', '', 'pref_key__highlight_code_monospace_font', false)
      this.switchRow('Auto-renumber ordered lists', '', 'pref_key__markdown__auto_renumber_ordered_list', false)
      this.row('Highlighting delay', '500 ms', 'pref_key__markdown__hl_delay_v2')
    }.width('100%')
  }

  @Builder view() {
    Column() {
      this.header('View Mode')
      this.switchRow('Open existing files in view mode', '', 'pref_key__is_preview_first', false)
      this.switchRow('Render for right-to-left languages', '', 'pref_key__is_render_rtl', false)
      this.row('Font Size', '15', 'pref_key__view_font_size')
      this.row('Link color', '#1976D2', 'pref_key__view_mode_link_color')
    }.width('100%')
  }

  @Builder format() {
    Column() {
      this.header(`Format — ${this.name}`)
      this.switchRow('Bigger headings', '', 'pref_key__markdown__bigger_headings_3', false)
      this.switchRow('Highlight line ending (2+ spaces)', '', 'pref_key__markdown__highlight_lineending_two_or_more_space', false)
      this.switchRow('Newline = new paragraph', '', 'pref_key__markdown__newline_newparagraph', false)
      this.row('Action order', '', 'pref_key__markdown__reorder_actions')
      this.row('Render math (KaTeX)', '', 'pref_key__markdown_render_math')
      this.row('Table of contents levels', '2-6', 'pref_key__markdown__table_of_contents_enabled_levels')
    }.width('100%')
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_arrow_back_white_24dp')).width(28).height(28).fillColor('#FFFFFF')
          .margin({ left: 8, right: 8 }).onClick(() => router.back())
        Text(this.name).fontSize(20).fontColor('#FFFFFF').layoutWeight(1)
      }.width('100%').height(56).backgroundColor('#1E2135').alignItems(VerticalAlign.Center)

      Scroll() {
        Column() {
          if (this.name === 'general') {
            this.general()
          } else if (this.name === 'editor') {
            this.editor()
          } else if (this.name === 'view') {
            this.view()
          } else {
            this.format()
          }
        }.backgroundColor('#FFFFFF').width('100%')
      }.layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#FFFFFF')
  }
}
