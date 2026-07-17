/**
 * EditorPage — Document editor (Markdown / Plain / Todo / etc.).
 *
 * Document editor with undo/redo/save/preview/search appbar and a bottom
 * text-actions toolbar. Component keys and ids stay stable for tests.
 *
 * Format radio group + File Settings submenu live in EditorPage per the
 * `editor_format_submenu` and `editor_*` ui_info page ids.
 */
import {
  SK, SEED_TODO_EXTRA_CONTEXTS, SEED_TODO_PROJECTS
} from '../model/AppModel';

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
  @StorageLink(SK.PREVIEW_FIRST) private previewMode: boolean = false;
  @State private todoDialog: string = '';
  @State private selectedTodoChoice: string = '';
  @State private searchText: string = '';
  @State private dueDate: string = '2026-12-31';

  // File-settings check items.
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
    ['action_checkbox', $r('app.media.ic_check_box_black_24dp'), 'Toggle checkbox'],
    ['action_h2', $r('app.media.format_header_2'), 'Heading 2'],
    ['action_h1', $r('app.media.format_header_1'), 'Heading 1'],
    ['action_indent', $r('app.media.ic_format_indent_increase_black_24dp'), 'Indent'],
    ['action_deindent', $r('app.media.ic_format_indent_decrease_black_24dp'), 'De-indent'],
    ['action_delete_lines', $r('app.media.ic_delete_black_24dp'), 'Delete lines'],
    ['action_duplicate', $r('app.media.ic_duplicate_lines_black_24dp'), 'Duplicate lines'],
    ['action_move_up', $r('app.media.ic_baseline_arrow_upward_24'), 'Move line up'],
  ];
  private todoActions: Array<[string, Resource, string]> = [
    ['action_sort', $r('app.media.ic_sort_black_24dp'), 'Sort by'],
    ['action_priority', $r('app.media.ic_priority_high_white_24dp'), 'Priority'],
    ['abid_todotxt_add_context', $r('app.media.ic_add_white_24dp'), 'Add context'],
    ['abid_todotxt_add_project', $r('app.media.ic_add_white_24dp'), 'Add project'],
    ['action_rotate', $r('app.media.ic_rotate_left_black_24dp'), 'Rotate'],
    ['action_toggle_done', $r('app.media.ic_check_box_black_24dp'), 'Toggle done'],
    ['action_time', $r('app.media.ic_access_time_black_24dp'), 'Date and time'],
    ['action_special_key', $r('app.media.ic_keyboard_black_24dp'), 'Special Key'],
    ['action_text_case', $r('app.media.ic_text_format_white_24dp'), 'Text Case'],
    ['action_delete_lines', $r('app.media.ic_delete_black_24dp'), 'Delete lines'],
    ['action_duplicate', $r('app.media.ic_content_copy_black_24dp'), 'Duplicate lines'],
    ['abid_todotxt_archive_done_tasks', $r('app.media.ic_file_gray_24dp'), 'Archive completed tasks'],
  ];

  private openTodoAction(key: string): void {
    this.selectedTodoChoice = '';
    if (key === 'abid_todotxt_add_context') {
      this.todoDialog = 'context';
    } else if (key === 'abid_todotxt_add_project') {
      this.todoDialog = 'project';
    } else if (key === 'abid_todotxt_archive_done_tasks') {
      this.todoDialog = 'archive';
    } else if (key === 'action_priority') {
      this.todoDialog = 'priority';
    } else if (key === 'action_time') {
      this.todoDialog = 'due';
    } else if (key === 'action_sort') {
      this.todoDialog = 'sort';
    }
  }

  private formatKey(label: string): string {
    if (label === 'Plain Text') {
      return 'format_option_plain_text';
    }
    if (label === 'To-Do') {
      return 'format_option_todo';
    }
    if (label === 'Markdown') {
      return 'format_option_markdown';
    }
    return 'format_option_other';
  }

  private toolbarClick(key: string): void {
    if (key === 'action_preview') {
      this.previewMode = !this.previewMode;
    } else if (key === 'action_search') {
      this.showSearch = !this.showSearch;
    }
  }

  @Builder todoChoice(label: string) {
    Row() {
      Radio({ value: label, group: 'todo_choice' }).checked(this.selectedTodoChoice === label)
      Text(label).fontSize(15).margin({ left: 10 }).layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
    .onClick(() => { this.selectedTodoChoice = label; })
  }

  @Builder todoActionDialog() {
    Column() {
      if (this.todoDialog === 'context') {
        Text('Add context').fontSize(18).fontWeight(FontWeight.Medium).width('100%').padding(16)
        ForEach(SEED_TODO_EXTRA_CONTEXTS, (item: string) => {
          this.todoChoice(item)
        }, (item: string) => item)
      } else if (this.todoDialog === 'project') {
        Text('Add project').fontSize(18).fontWeight(FontWeight.Medium).width('100%').padding(16)
        Scroll() {
          Column() {
            ForEach(SEED_TODO_PROJECTS, (item: string) => {
              this.todoChoice(item)
            }, (item: string) => item)
          }.width('100%')
        }.height(190).width('100%')
      } else if (this.todoDialog === 'priority') {
        Text('Priority').fontSize(18).fontWeight(FontWeight.Medium).width('100%').padding(16)
        ForEach(['A', 'B', 'C', 'Clear priority'], (item: string) => {
          this.todoChoice(item)
        }, (item: string) => item)
      } else if (this.todoDialog === 'due') {
        Text('Due date').fontSize(18).fontWeight(FontWeight.Medium).width('100%').padding(16)
        TextInput({ text: this.dueDate })
          .id('todotxt_due_date_input')
          .onChange((value: string) => { this.dueDate = value; })
          .margin({ left: 16, right: 16 })
        Button('Clear due date').key('todotxt_clear_due')
      } else if (this.todoDialog === 'sort') {
        Text('Sort by').fontSize(18).fontWeight(FontWeight.Medium).width('100%').padding(16)
        ForEach(['Priority', 'Name', 'Due date'], (item: string) => {
          this.todoChoice(item)
        }, (item: string) => item)
      } else {
        Text('Archive completed tasks').fontSize(18).fontWeight(FontWeight.Medium).width('100%').padding(16)
        Text('Move completed tasks to').fontSize(13).fontColor('#757575').width('100%')
          .padding({ left: 16, right: 16 })
        Text('done.txt').fontSize(16).width('100%').padding(16).key('todotxt_archive_target')
      }
      Row() {
        Button('CANCEL').backgroundColor(Color.Transparent).fontColor('#1976D2')
          .onClick(() => { this.todoDialog = ''; })
        Button('OK').backgroundColor(Color.Transparent).fontColor('#1976D2').margin({ left: 8 })
          .onClick(() => { this.todoDialog = ''; })
      }.width('100%').justifyContent(FlexAlign.End).padding({ right: 8, bottom: 8 })
    }
    .width('92%')
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#E0E0E0' })
    .key(`todotxt_${this.todoDialog}_dialog`)
  }

  @Builder toolbarAction(icon: Resource, key: string, desc: string) {
    Image(icon).width(28).height(28).fillColor('#FFFFFF').key(key)
      .accessibilityText(desc)
      .margin({ left: 8, right: 8 }).onClick(() => { this.toolbarClick(key); })
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
                  .key(this.formatKey(f))
                  .onChange((c: boolean) => { if (c) { this.showFormatRadio = false; } })
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
          Row() { Text('Export PDF').fontSize(15).layoutWeight(1) }.width('100%').padding(12)
            .key('action_export_pdf').onClick(() => {})
        }.width('100%').backgroundColor('#FFFFFF').border({ width: { bottom: 1 }, color: '#E0E0E0' })
      }

      // Tools submenu
      if (this.showToolsSub) {
        Column() {
          Row() { Text('Search / Replace').fontSize(15).layoutWeight(1) }.width('100%').padding(12)
          Row() { Text('Set due date').fontSize(15).layoutWeight(1) }.width('100%').padding(12)
          Row() { Text('Sort tasks').fontSize(15).layoutWeight(1) }.width('100%').padding(12)
            .onClick(() => { this.showToolsSub = false; })
        }.width('100%').backgroundColor('#FFFFFF').border({ width: { bottom: 1 }, color: '#E0E0E0' })
      }

      // Search edit panel
      if (this.showSearch) {
        Column() {
          Row() {
            TextInput({ text: this.searchText, placeholder: 'Search for' })
              .id('editor_search_input')
              .onChange((value: string) => { this.searchText = value; })
              .layoutWeight(1).fontSize(14)
            Button('Replace').backgroundColor('#FFFFFF').fontColor('#1976D2').fontSize(13)
          }.width('100%').padding(8)
          Row() {
            Text('Matches: 0').fontSize(12).fontColor('#757575').layoutWeight(1)
              .key('editor_search_match_count')
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
         .key('editor_preview_surface')
      } else {
        TextArea({ text: this.body })
          .width('100%').layoutWeight(1)
          .fontSize(15)
          .fontFamily('monospace')
          .id('document__fragment__edit__highlighting_editor')
          .onChange((v: string) => { AppStorage.set<string>(SK.EDITOR_TEXT, v); })
      }

      if (this.todoDialog.length > 0) {
        this.todoActionDialog()
      }

      if (this.format === 'To-Do') {
        Button('Add context')
          .id('abid_todotxt_add_context')
          .key('abid_todotxt_add_context')
          .height(40)
          .onClick(() => { this.openTodoAction('abid_todotxt_add_context'); })
      }

      // Bottom text-actions toolbar
      Scroll() {
        Row() {
          if (this.format === 'To-Do') {
            ForEach(this.todoActions, (a: [string, Resource, string]) => {
              Column() {
                Image(a[1]).width(20).height(20).fillColor('#424242')
                  .accessibilityText(a[2]).accessibilityDescription(a[2])
              }.width(24).height(56).justifyContent(FlexAlign.Center)
                .id(a[0]).key(a[0])
                .onClick(() => { this.openTodoAction(a[0]); })
            }, (a: [string, Resource, string]) => a[0])
          } else {
            ForEach(this.mdActions, (a: [string, Resource, string]) => {
              Column() {
                Image(a[1]).width(20).height(20).fillColor('#424242')
                  .accessibilityText(a[2]).accessibilityDescription(a[2])
              }.width(24).height(56).justifyContent(FlexAlign.Center)
                .id(a[0]).key(a[0])
                .onClick(() => { this.openTodoAction(a[0]); })
            }, (a: [string, Resource, string]) => a[0])
          }
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
