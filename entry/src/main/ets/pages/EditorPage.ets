/**
 * EditorPage — Document editor (Markdown / Plain / Todo / etc.).
 *
 * Mirrors Android DocumentActivity: appbar with undo/redo/save/preview/search +
 * bottom text-actions toolbar (format buttons). Component keys + ids mirror
 * labels.py EDITOR_* and ED_*_*.
 *
 * Format radio group + File Settings submenu live in EditorPage per the
 * `editor_format_submenu` and `editor_*` ui_info page ids.
 */
import { SK, ROUTE } from '../model/AppModel';

@Entry
@Component
struct EditorPage {
  @StorageLink(SK.EDITOR_TEXT) private body: string = '';
  @StorageLink(SK.EDITOR_TITLE) private title: string = 'sample';
  @StorageLink(SK.EDITOR_FORMAT) private format: string = 'Markdown';
  @State private showFileSettings: boolean = false;
  @State private showFormatRadio: boolean = false;
  @State private showShareSub: boolean = false;
  @State private showToolsSub: boolean = false;
  @State private showSearch: boolean = false;
  @State private previewMode: boolean = false;

  // File-settings check items (mirror labels ED_*_KEY)
  @State private wordWrap: boolean = true;
  @State private lineNumbers: boolean = false;
  @State private highlighting: boolean = true;
  @State private autoFormat: boolean = true;

  private mdActions: Array<[string, Resource, string]> = [
    ['action_unordered_list', $r('app.media.ic_format_list_bulleted_black_24dp'), 'Unordered list'],
    ['action_ordered_list', $r('app.media.ic_format_list_numbered_black_24dp'), 'Ordered list'],
    ['action_rotate', $r('app.media.ic_rotate_left_black_24dp'), 'Rotate'],
    ['action_time', $r('app.media.ic_access_time_black_24dp'), 'Date and time'],
    ['action_special_key', $r('app.media.ic_keyboard_black_24dp'), 'Special Key'],
    ['action_inline_code', $r('app.media.ic_code_black_24dp'), 'Inline code'],
    ['action_bold', $r('app.media.ic_format_bold_black_24dp'), 'Bold'],
    ['action_h2', $r('app.media.format_header_2'), 'Heading 2'],
    ['action_h1', $r('app.media.format_header_1'), 'Heading 1'],
  ];
  private todoActions: Array<[string, Resource, string]> = [
    ['action_sort', $r('app.media.ic_sort_black_24dp'), 'Sort by'],
    ['action_priority', $r('app.media.ic_priority_high_white_24dp'), 'Priority'],
    ['action_rotate', $r('app.media.ic_rotate_left_black_24dp'), 'Rotate'],
    ['action_toggle_done', $r('app.media.ic_check_box_black_24dp'), 'Toggle done'],
    ['action_time', $r('app.media.ic_access_time_black_24dp'), 'Date and time'],
    ['action_special_key', $r('app.media.ic_keyboard_black_24dp'), 'Special Key'],
    ['action_text_case', $r('app.media.ic_text_format_white_24dp'), 'Text Case'],
    ['action_delete_lines', $r('app.media.ic_delete_black_24dp'), 'Delete lines'],
    ['action_duplicate', $r('app.media.ic_content_copy_black_24dp'), 'Duplicate lines'],
  ];

  private get actions(): Array<[string, Resource, string]> {
    return this.format === 'To-Do' ? this.todoActions : this.mdActions;
  }

  @Builder toolbarAction(icon: Resource, key: string, desc: string) {
    Image(icon).width(28).height(28).fillColor('#FFFFFF').key(key)
      .margin({ left: 8, right: 8 }).onClick(() => {})
  }

  build() {
    Column() {
      // Appbar — D1: Android editor toolbar begins with the document title (no back arrow).
      Row() {
        Text(this.title).fontColor('#FFFFFF').fontSize(18).layoutWeight(1).margin({ left: 16 })
        this.toolbarAction($r('app.media.ic_undo_black_24dp'), 'action_undo', 'Undo')
        this.toolbarAction($r('app.media.ic_redo_black_24dp'), 'action_redo', 'Redo')
        this.toolbarAction($r('app.media.ic_save_black_24dp'), 'action_save', 'Save')
        this.toolbarAction($r('app.media.ic_visibility_black_24dp'), 'action_preview', 'View Mode')
        this.toolbarAction($r('app.media.ic_search_black_24dp'), 'action_search', 'Search')
        Image($r('app.media.ic_more_vert_black_24dp')).width(28).height(28).fillColor('#FFFFFF')
          .margin({ left: 8, right: 12 })
          .key('action_overflow')
          .onClick(() => { this.showFileSettings = !this.showFileSettings; })
      }.width('100%').height(56).backgroundColor('#1E2135').alignItems(VerticalAlign.Center)
       .key('editor_toolbar_title')

      // File-settings submenu (drop-down)
      if (this.showFileSettings) {
        Column() {
          Row() { Text('File Settings').fontSize(15).layoutWeight(1) }.width('100%').padding(14)
            .onClick(() => { this.showFormatRadio = true; this.showFileSettings = false; })
          Row() {
            Text('Wrap words').fontSize(15).layoutWeight(1)
            Checkbox().select(this.wordWrap).key('action_wrap_words')
              .onChange((v: boolean) => { this.wordWrap = v; })
          }.width('100%').padding(14)
          Row() {
            Text('Line numbers').fontSize(15).layoutWeight(1)
            Checkbox().select(this.lineNumbers).key('action_line_numbers')
              .onChange((v: boolean) => { this.lineNumbers = v; })
          }.width('100%').padding(14)
          Row() {
            Text('Highlighting').fontSize(15).layoutWeight(1)
            Checkbox().select(this.highlighting).key('action_enable_highlighting')
              .onChange((v: boolean) => { this.highlighting = v; })
          }.width('100%').padding(14)
          Row() {
            Text('Auto-format').fontSize(15).layoutWeight(1)
            Checkbox().select(this.autoFormat).key('action_enable_auto_format')
              .onChange((v: boolean) => { this.autoFormat = v; })
          }.width('100%').padding(14)
          Row() { Text('Reload').fontSize(15).layoutWeight(1) }.width('100%').padding(14).key('action_reload')
          Row() { Text('Info').fontSize(15).layoutWeight(1) }.width('100%').padding(14).key('action_info')
          Row() { Text('Show file browser').fontSize(15).layoutWeight(1) }.width('100%').padding(14)
            .key('action_show_file_browser')
          Row() { Text('Share path').fontSize(15).layoutWeight(1) }.width('100%').padding(14)
            .key('action_share_path').onClick(() => { this.showShareSub = true; this.showFileSettings = false; })
          Row() { Text('Tools').fontSize(15).layoutWeight(1) }.width('100%').padding(14)
            .onClick(() => { this.showToolsSub = true; this.showFileSettings = false; })
        }.width('100%').backgroundColor('#FFFFFF').border({ width: { bottom: 1 }, color: '#E0E0E0' })
      }

      // Format radio group submenu
      if (this.showFormatRadio) {
        Column() {
          Text('Format').fontSize(14).fontColor('#757575').width('100%').padding({ left: 14, top: 8 })
          ForEach(['Markdown', 'Plain Text', 'To-Do', 'Wikitext / Zim', 'AsciiDoc', 'OrgMode', 'CSV', 'Key - Value'],
            (f: string) => {
              Row() {
                Radio({ value: f, group: 'format_group' }).checked(this.format === f)
                  .onChange((c: boolean) => { if (c) { this.format = f; this.showFormatRadio = false; } })
                Text(f).fontSize(15).margin({ left: 8 })
              }.width('100%').padding(12)
            }, (f: string) => f)
        }.width('100%').backgroundColor('#FFFFFF').key('action_format_group')
         .border({ width: { bottom: 1 }, color: '#E0E0E0' })
      }

      // Share submenu
      if (this.showShareSub) {
        Column() {
          Row() { Text('Share text').fontSize(15).layoutWeight(1) }.width('100%').padding(12).key('action_share_text')
          Row() { Text('Share file').fontSize(15).layoutWeight(1) }.width('100%').padding(12).key('action_share_file')
          Row() { Text('Share HTML').fontSize(15).layoutWeight(1) }.width('100%').padding(12).key('action_share_html')
          Row() { Text('Share HTML source').fontSize(15).layoutWeight(1) }.width('100%').padding(12)
            .key('action_share_html_source')
        }.width('100%').backgroundColor('#FFFFFF').border({ width: { bottom: 1 }, color: '#E0E0E0' })
      }

      // Tools submenu
      if (this.showToolsSub) {
        Column() {
          Row() { Text('Search / Replace').fontSize(15).layoutWeight(1) }.width('100%').padding(12)
          Row() { Text('Print / PDF').fontSize(15).layoutWeight(1) }.width('100%').padding(12)
          Row() { Text('Set due date').fontSize(15).layoutWeight(1) }.width('100%').padding(12)
          Row() { Text('Sort tasks').fontSize(15).layoutWeight(1) }.width('100%').padding(12)
            .onClick(() => { this.showToolsSub = false; })
        }.width('100%').backgroundColor('#FFFFFF').border({ width: { bottom: 1 }, color: '#E0E0E0' })
      }

      // Search edit panel
      if (this.showSearch) {
        Column() {
          Row() {
            TextInput({ placeholder: 'Search for' }).layoutWeight(1).fontSize(14)
            Button('Replace').backgroundColor('#FFFFFF').fontColor('#1976D2').fontSize(13)
          }.width('100%').padding(8)
          Row() {
            Text('Matches: 0').fontSize(12).fontColor('#757575').layoutWeight(1)
            Button('Prev').backgroundColor('#FFFFFF').fontColor('#1976D2').fontSize(13)
            Button('Next').backgroundColor('#FFFFFF').fontColor('#1976D2').fontSize(13).margin({ left: 4 })
          }.width('100%').padding(8)
        }.width('100%').backgroundColor('#FFFFFF').border({ width: { bottom: 1 }, color: '#E0E0E0' })
      }

      // Editor / preview
      if (this.previewMode) {
        Column() {
          Text(this.body).fontSize(15).padding(16).textAlign(TextAlign.Start).width('100%')
        }.layoutWeight(1).backgroundColor('#FFFFFF').alignItems(HorizontalAlign.Start)
      } else {
        TextArea({ text: this.body })
          .width('100%').layoutWeight(1)
          .fontSize(15)
          .fontFamily('monospace')
          .id('document__fragment__edit__highlighting_editor')
          .onChange((v: string) => { AppStorage.setOrCreate<string>(SK.EDITOR_TEXT, v); })
      }

      // Bottom text-actions toolbar
      Scroll() {
        Row() {
          ForEach(this.actions, (a: [string, Resource, string]) => {
            Column() {
              Image(a[1]).width(28).height(28).fillColor('#424242')
            }.height(56).justifyContent(FlexAlign.Center).padding({ left: 12, right: 12 }).key(a[0]).onClick(() => {})
          }, (a: [string, Resource, string]) => a[0])
        }.height(56).alignItems(VerticalAlign.Center)
      }.scrollable(ScrollDirection.Horizontal)
       .scrollBar(BarState.Off)
       .align(Alignment.Start)
       .width('100%').height(56)
       .backgroundColor('#FAFAFA')
       .border({ width: { top: 1 }, color: '#E0E0E0' })
       .id('document__fragment__edit__text_actions_bar')
    }.width('100%').height('100%').backgroundColor('#FFFFFF')
  }
}
