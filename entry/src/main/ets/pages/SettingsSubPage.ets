import router from '@ohos.router';
import { SK, TAB } from '../model/AppModel';

@Entry
@Component
struct SettingsSubPage {
  @State private name: string = 'general';
  @State private choice: string = '';
  @StorageLink(SK.NOTEBOOK_LOCATION) private notebookLocation: string = 'Documents/markor';
  @StorageLink(SK.START_TAB) private startTab: number = TAB.NOTEBOOK;
  @StorageLink(SK.THEME) private theme: string = 'System';
  @StorageLink(SK.COLOR_PRESET) private colorPreset: string = 'Default';
  @StorageLink(SK.HIGHLIGHT_ENABLED) private highlighting: boolean = true;
  @StorageLink(SK.PREVIEW_FIRST) private previewFirst: boolean = false;
  @State private startTabSummary: string = 'Notebook';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params && params.name) {
      this.name = params.name;
    }
    this.startTabSummary = this.startTabLabel();
  }

  private startTabLabel(): string {
    if (this.startTab === TAB.TODO) {
      return 'To-Do';
    }
    if (this.startTab === TAB.QUICKNOTE) {
      return 'QuickNote';
    }
    if (this.startTab === TAB.MORE) {
      return 'More';
    }
    return 'Notebook';
  }

  private options(): string[] {
    if (this.choice === 'notebook') {
      return ['Documents/markor', 'Documents/notes'];
    }
    if (this.choice === 'start_tab') {
      return ['Notebook', 'To-Do', 'QuickNote', 'More'];
    }
    if (this.choice === 'theme') {
      return ['System', 'Light', 'Dark'];
    }
    if (this.choice === 'color') {
      return ['Default', 'Solarized'];
    }
    return [];
  }

  private choose(_value: string, _choiceType: string): void {
    // Public Base shell: choices remain visible and clickable, but no scored
    // preference summary, state, persistence, or downstream behavior is committed.
    this.choice = '';
  }

  @Builder
  header(text: string) {
    Text(text).fontSize(13).fontColor('#1976D2').fontWeight(FontWeight.Medium)
      .width('100%').padding({ left: 16, top: 16, bottom: 8 })
  }

  @Builder
  row(title: string, summary: string, key: string, choice: string = '') {
    Row() {
      Column() {
        Text(title).fontSize(15).fontColor('#212121')
        if (summary.length > 0) {
          Text(summary).fontSize(12).fontColor('#757575').margin({ top: 2 })
        }
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .key(key)
    .onClick(() => {
      if (choice.length > 0) {
        this.choice = choice;
      }
    })
  }

  @Builder
  general() {
    Column() {
      this.header('Save location')
      this.row('Notebook', this.notebookLocation, 'pref_key__notebook_directory', 'notebook')
      this.row('QuickNote', 'Documents/markor/quicknote.md', 'pref_key__quicknote_filepath')
      this.row('To-Do', 'Documents/markor/todo.todo.txt', 'pref_key__todo_filepath')
      this.header('Application')
      Row() {
        Column() {
          Text('App start tab').fontSize(15).fontColor('#212121')
          Text(this.startTabSummary).fontSize(12).fontColor('#757575').margin({ top: 2 })
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .key('pref_key__app_start_tab_v2')
      .onClick(() => { this.choice = 'start_tab'; })
      this.row('Theme', this.theme, 'pref_key__app_theme', 'theme')
      this.row(
        'Basic color scheme',
        this.colorPreset,
        'pref_key__basic_color_scheme_solarized',
        'color',
      )
      this.row('Language', 'System', 'pref_key__language')
      this.row('Storage permission request', 'Enabled', 'pref_platform_storage_permission')
      this.row('Disallow screenshots', 'Enabled', 'pref_platform_disallow_screenshots')
      this.row('Special launcher alias', 'Enabled', 'pref_platform_launcher_alias')
      this.header('Settings transfer')
      Row() {
        Column() {
          Text('Backup settings').fontSize(15)
          Text('Unavailable on this platform').fontSize(12).fontColor('#757575')
        }.alignItems(HorizontalAlign.Start)
      }.width('100%').padding(12).key('pref_key__backup_settings').enabled(false)
      Row() {
        Column() {
          Text('Restore settings').fontSize(15)
          Text('Unavailable on this platform').fontSize(12).fontColor('#757575')
        }.alignItems(HorizontalAlign.Start)
      }.width('100%').padding(12).key('pref_key__restore_settings').enabled(false)
    }.width('100%')
  }

  @Builder
  editor() {
    Column() {
      this.header('Editor')
      Row() {
        Column() {
          Text('Syntax Highlighting').fontSize(15)
          Text('Highlight entered text').fontSize(12).fontColor('#757575')
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        Toggle({ type: ToggleType.Switch, isOn: this.highlighting })
          .key('pref_key__is_highlighting_activated')
          .onChange((_value: boolean) => {})
      }.width('100%').padding(12)
      this.row('Font Size', '15', 'pref_key__editor_font_size')
      this.row('Line Spacing', '100%', 'pref_key__editor_line_spacing')
      this.row('Action order', 'Default', 'pref_key__markdown__reorder_actions')
    }.width('100%')
  }

  @Builder
  view() {
    Column() {
      this.header('View Mode')
      Row() {
        Text('Open existing files in view mode').fontSize(15).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.previewFirst })
          .key('pref_key__is_preview_first')
          .onChange((_value: boolean) => {})
      }.width('100%').padding(12)
      this.row('Link color', '#1976D2', 'pref_key__view_mode_link_color')
      this.row('Font Size', '15', 'pref_key__view_font_size')
    }.width('100%')
  }

  @Builder
  format() {
    Column() {
      this.header(`Format - ${this.name.replace('format/', '')}`)
      if (this.name === 'format/To-Do') {
        this.row(
          'Additional projects and contexts',
          '+music +video @home @shop',
          'pref_key__todotxt__additional_projects_contexts',
        )
        this.row(
          'Action order',
          'Sort, Priority, Context, Project, Due date, Archive',
          'pref_key__todotxt__reorder_actions',
        )
      } else {
        this.row('Action order', 'Default', 'pref_key__markdown__reorder_actions')
        this.row('Table of contents levels', '2-6',
          'pref_key__markdown__table_of_contents_enabled_levels')
      }
    }.width('100%')
  }

  @Builder
  choiceSheet(choiceType: string) {
    Column() {
      Text('Choose option').fontSize(18).padding(16)
      ForEach(this.options(), (value: string) => {
        Text(value)
          .fontSize(16)
          .textAlign(TextAlign.Center)
          .width('100%')
          .height(48)
          .key('settings_choice__' + value)
          .onClick(() => { this.choose(value, choiceType); })
      }, (value: string) => value)
      Button('CANCEL').onClick(() => { this.choice = ''; })
    }
    .width('88%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#E0E0E0' })
    .key('settings_choice_dialog')
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Image($r('app.media.ic_arrow_back_white_24dp')).width(28).height(28)
            .fillColor('#FFFFFF').margin({ left: 8, right: 8 }).onClick(() => router.back())
          Text(this.name).fontSize(20).fontColor('#FFFFFF').layoutWeight(1)
        }.width('100%').height(56).backgroundColor('#1E2135').alignItems(VerticalAlign.Center)

        Scroll() {
          if (this.name === 'general') {
            this.general()
          } else if (this.name === 'editor') {
            this.editor()
          } else if (this.name === 'view') {
            this.view()
          } else {
            this.format()
          }
        }.layoutWeight(1).backgroundColor('#FFFFFF')
      }.width('100%').height('100%')

      if (this.choice.length > 0) {
        this.choiceSheet(this.choice)
      }
    }.width('100%').height('100%').backgroundColor('#FFFFFF')
  }
}
