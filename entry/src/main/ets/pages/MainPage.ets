import router from '@ohos.router';
import { FsEntry, ROUTE, SEED_TODO_TEXT, SK, TAB } from '../model/AppModel';
import { NewFileDialog } from '../component/NewFileDialog';

@Entry
@Component
struct MainPage {
  @StorageLink(SK.CUR_TAB) private curTab: number = TAB.NOTEBOOK;
  @StorageLink(SK.NOTEBOOK_ENTRIES) private entries: FsEntry[] = [];
  @StorageLink(SK.FILE_CONTENTS) private fileContents: Record<string, string> = {};
  @StorageLink(SK.QUICKNOTE_TEXT) private quickNote: string = '';
  @StorageLink(SK.CUR_FOLDER) private currentFolder: string = '';
  @StorageLink(SK.VIRTUAL_FOLDER) private virtualFolder: string = 'Notebook';
  @StorageLink(SK.NEW_FILE_DIALOG_VISIBLE) private nfdVisible: boolean = false;
  @State private selectedNames: string[] = [];
  @State private searchVisible: boolean = false;
  @State private searchQuery: string = '';
  @State private activeOverlay: string = '';
  // UI-shell-only selection for neutral To-Do menus. It is never written to
  // document text, the fixture model, files, or preferences.
  @State private todoActionChoice: string = '';
  @State private dialogInput: string = '';

  private openTodoOverlay(name: string): void {
    this.todoActionChoice = '';
    this.activeOverlay = name;
  }

  private folderEntryList(): FsEntry[] {
    return this.entries.filter((entry: FsEntry) => {
      if (this.currentFolder.length === 0) {
        return entry.path.indexOf('/') < 0;
      }
      const prefix: string = this.currentFolder + '/';
      if (!entry.path.startsWith(prefix)) {
        return false;
      }
      return entry.path.slice(prefix.length).indexOf('/') < 0;
    });
  }

  private visibleEntryList(): FsEntry[] {
    if (this.virtualFolder !== 'Notebook') {
      return [];
    }
    const query: string = this.searchQuery.trim().toLowerCase();
    const folderEntries: FsEntry[] = this.folderEntryList();
    if (query.length === 0) {
      return folderEntries;
    }
    return folderEntries.filter((entry: FsEntry) => entry.name.toLowerCase().includes(query));
  }

  private openFile(entry: FsEntry): void {
    AppStorage.set<string>(SK.EDITOR_PATH, entry.path);
    AppStorage.set<string>(SK.EDITOR_TITLE, entry.name);
    AppStorage.set<string>(SK.EDITOR_TEXT, this.fileContents[entry.path] ?? '');
    AppStorage.set<string>(
      SK.EDITOR_FORMAT,
      entry.name.endsWith('.todo.txt') ? 'To-Do' : 'Markdown',
    );
    AppStorage.set<string>(SK.CUR_ROUTE, ROUTE.EDITOR);
    router.pushUrl({ url: ROUTE.EDITOR });
  }

  private resetSelection(): void {
    this.selectedNames = [];
  }

  @Builder
  navItem(label: string, icon: Resource, key: string, index: number) {
    Column() {
      Image(icon).width(24).height(24)
        .fillColor(this.curTab === index ? '#F04B4B' : '#FFFFFF')
      Text(label).fontSize(12).margin({ top: 4 })
        .fontColor(this.curTab === index ? '#F04B4B' : '#FFFFFF')
    }
    .key(key)
    .accessibilityText(label)
    .accessibilityDescription(this.curTab === index ? 'selected' : 'not selected')
    .layoutWeight(1)
    .height(56)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.curTab = index;
      this.resetSelection();
    })
  }

  @Builder
  selectionActions() {
    Scroll() {
      Row({ space: 4 }) {
        Button('Select all').key('action_select_all')
          .onClick(() => {})
        Button('Clear selection').key('action_clear_selection')
          .onClick(() => this.resetSelection())
        Button('Delete').key('action_delete')
          .onClick(() => { this.activeOverlay = 'delete'; })
        if (this.selectedNames.length === 1) {
          Button('Rename').key('action_rename')
            .onClick(() => {
              this.dialogInput = this.selectedNames[0];
              this.activeOverlay = 'rename';
            })
        }
        Button('Move').key('action_move')
          .onClick(() => { this.activeOverlay = 'move'; })
        Button('Add to favourites').key('action_favourite')
          .onClick(() => {})
        Button('Create desktop shortcut').key('action_desktop_shortcut')
          .onClick(() => {})
      }.height(48).alignItems(VerticalAlign.Center)
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }

  @Builder
  notebookToolbar() {
    Column() {
      Row() {
        if (this.selectedNames.length > 0) {
          Text(`${this.selectedNames.length}/${this.visibleEntryList().length}`)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .margin({ left: 16 })
            .fontColor('#FFFFFF')
            .key('notebook_selection_count')
        } else {
          if (this.currentFolder.length > 0) {
            Button('Up').key('notebook_up').backgroundColor(Color.Transparent).fontColor('#FFFFFF')
              .onClick(() => {
                const slash: number = this.currentFolder.lastIndexOf('/');
                this.currentFolder = slash < 0 ? '' : this.currentFolder.slice(0, slash);
              })
          }
          Text(this.currentFolder.length > 0 ? this.currentFolder : this.virtualFolder)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .margin({ left: 16 })
            .fontColor('#FFFFFF')
          Image($r('app.media.ic_baseline_rule_folder_24')).width(28).height(28)
            .fillColor('#FFFFFF').key('action_go_to').onClick(() => { this.activeOverlay = 'goto'; })
          Image($r('app.media.ic_sort_black_24dp')).width(28).height(28)
            .fillColor('#FFFFFF').key('action_sort').margin({ left: 8 })
            .onClick(() => { this.activeOverlay = 'sort'; })
          Image($r('app.media.ic_search_black_24dp')).width(28).height(28)
            .fillColor('#FFFFFF').key('action_search').margin({ left: 8, right: 12 })
            .onClick(() => { this.searchVisible = !this.searchVisible; })
        }
      }
      .width('100%')
      .height(56)
      .backgroundColor('#1E2135')
      .alignItems(VerticalAlign.Center)
      .key('notebook_toolbar_title')

      if (this.selectedNames.length > 0) {
        this.selectionActions()
      } else if (this.searchVisible) {
        Search({ value: this.searchQuery, placeholder: 'Search notebook' })
          .id('notebook_search_input')
          .key('notebook_filter_search')
          .onChange((_value: string) => {})
          .width('100%')
          .height(48)
      }
    }.width('100%').backgroundColor('#1E2135')
  }

  @Builder
  notebookList() {
    if (this.visibleEntryList().length === 0) {
      Column() {
        Text('No files in this view').fontSize(16).fontColor('#757575')
      }
      .layoutWeight(1)
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      List() {
        ForEach(this.visibleEntryList(), (entry: FsEntry) => {
          ListItem() {
            Row() {
              Image(entry.isFolder ? $r('app.media.ic_folder_gray_24dp') : $r('app.media.ic_file_gray_24dp'))
                .width(28).height(28).fillColor('#757575')
              Column() {
                Text(entry.name)
                  .fontSize(16)
                  .fontColor('#212121')
                  .id('opoc_filesystem_item__title')
                  .accessibilityText(entry.name)
                Text(entry.description).fontSize(12).fontColor('#757575').margin({ top: 2 })
              }.layoutWeight(1).margin({ left: 12 }).alignItems(HorizontalAlign.Start)
              if (this.selectedNames.includes(entry.name)) {
                Text('Selected').fontSize(12).fontColor('#1976D2')
              }
            }
            .width('100%')
            .height(72)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
            .key('notebook_row__' + entry.path)
            .accessibilityText(entry.name)
            .onClick(() => {
              if (this.selectedNames.length > 0) {
                if (this.selectedNames.includes(entry.name)) {
                  this.selectedNames =
                    this.selectedNames.filter((name: string) => name !== entry.name);
                } else {
                  this.selectedNames = [...this.selectedNames, entry.name];
                }
              } else if (entry.isFolder) {
                this.currentFolder = entry.path;
              } else {
                this.openFile(entry);
              }
            })
            .gesture(LongPressGesture().onAction(() => {
              if (!this.selectedNames.includes(entry.name)) {
                this.selectedNames = [...this.selectedNames, entry.name];
              }
            }))
          }
        }, (entry: FsEntry) => entry.path)
      }
      .layoutWeight(1)
      .id('ui__filesystem_dialog__list')
      .divider({ strokeWidth: 1, color: '#F0F0F0', startMargin: 56 })
    }
  }

  @Builder
  buildNotebookTab() {
    Column() {
      this.notebookToolbar()
      this.notebookList()
      Flex({ justifyContent: FlexAlign.End, alignItems: ItemAlign.End }) {
        Column() {
          Image($r('app.media.ic_add_white_24dp')).width(28).height(28).fillColor('#FFFFFF')
        }
        .width(56)
        .height(56)
        .borderRadius(28)
        .backgroundColor('#F04B4B')
        .margin({ right: 16, bottom: 16 })
        .key('fab_add_new_item')
        .accessibilityText('Create a new file or folder')
        .onClick(() => { this.nfdVisible = true; })
        .gesture(LongPressGesture().onAction(() => { this.activeOverlay = 'goto'; }))
      }.width('100%')
    }.width('100%').layoutWeight(1)
  }

  @Builder
  editorTab(text: string, todo: boolean) {
    Column() {
      Row() {
        Text(todo ? 'To-Do' : 'QuickNote').fontSize(20).fontColor('#FFFFFF')
          .layoutWeight(1).margin({ left: 16 })
        Image($r('app.media.ic_save_black_24dp')).width(28).height(28)
          .fillColor('#FFFFFF').key('action_save').margin({ right: 12 })
      }.width('100%').height(56).backgroundColor('#1E2135').alignItems(VerticalAlign.Center)
      TextArea({ text: text })
        .id('document__fragment__edit__highlighting_editor')
        .layoutWeight(1)
        .width('100%')
        .fontFamily('monospace')
        .onChange((value: string) => {
          if (!todo) {
            this.quickNote = value;
          }
        })
      if (todo) {
        // These toolbar affordances intentionally present neutral UI only. The
        // shell must not alter the seeded todo text or persist an action.
        Scroll() {
          Row({ space: 12 }) {
            Button('Sort').key('action_sort').onClick(() => this.openTodoOverlay('todo_sort'))
            Button('Complete').key('action_toggle_done').onClick(() => this.openTodoOverlay('todo_complete'))
            Button('Priority').key('action_priority').onClick(() => this.openTodoOverlay('todo_priority'))
            Button('Due date').key('action_time').onClick(() => this.openTodoOverlay('todo_due_date'))
            Button('Add context').key('abid_todotxt_add_context').onClick(() => this.openTodoOverlay('todo_context'))
            Button('Add project').key('abid_todotxt_add_project').onClick(() => this.openTodoOverlay('todo_project'))
            Button('Archive completed tasks').key('abid_todotxt_archive_done_tasks')
              .onClick(() => this.openTodoOverlay('todo_archive'))
          }.height(52).padding(12).alignItems(VerticalAlign.Center)
        }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).width('100%').height(52)
      }
    }.width('100%').layoutWeight(1)
  }

  @Builder
  moreRow(title: string, key: string, route: string) {
    ListItem() {
      Row() {
        Text(title).fontSize(15).layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 18, bottom: 18 })
      .key(key)
      .onClick(() => {
        AppStorage.set<string>(SK.CUR_ROUTE, route);
        router.pushUrl({ url: route });
      })
    }
  }

  @Builder
  buildMoreTab() {
    Column() {
      Row() {
        Text('More').fontSize(20).fontColor('#FFFFFF').margin({ left: 16 })
      }.width('100%').height(56).backgroundColor('#1E2135').alignItems(VerticalAlign.Center)
      List() {
        ListItem() {
          Column() {
            Text('Markor').fontSize(18)
            Text('Version v2.16.1').fontSize(12).fontColor('#757575')
          }.width('100%').padding(20).alignItems(HorizontalAlign.Start)
        }
        this.moreRow('Settings', 'pref_key__more_info__settings', ROUTE.SETTINGS)
        this.moreRow('Share into', 'pref_key__more_info__share_into', ROUTE.SHARE_INTO)
        this.moreRow('Introduction', 'pref_key__more_info__introduction', ROUTE.INTRO)
        this.moreRow('Storage permission', 'pref_key__more_info__permission', ROUTE.PERMISSION)
        ListItem() {
          Row() {
            Text('Copy build information').fontSize(15).layoutWeight(1)
          }.width('100%').padding(18).key('pref_key__more_info__copy_build_information')
        }
        ListItem() {
          Row() {
            Text('Project license').fontSize(15).layoutWeight(1)
          }.width('100%').padding(18).key('pref_key__more_info__project_license')
        }
        ListItem() {
          Row() {
            Text('Contributors').fontSize(15).layoutWeight(1)
          }.width('100%').padding(18).key('pref_key__more_info__contributors_public_info')
        }
      }.layoutWeight(1).divider({ strokeWidth: 1, color: '#F0F0F0' })
    }.width('100%').layoutWeight(1)
  }

  @Builder
  actionDialog() {
    Column() {
      if (this.activeOverlay === 'delete') {
        Text('Delete selected files?').fontSize(18).padding(16)
      } else if (this.activeOverlay === 'rename') {
        Text('Rename file').fontSize(18).padding(16)
        TextInput({ text: this.dialogInput })
          .id('rename_dialog__name')
          .onChange((value: string) => { this.dialogInput = value; })
          .margin({ left: 16, right: 16 })
      } else if (this.activeOverlay === 'move') {
        Text('Move to folder').fontSize(18).padding(16)
        Button('sub').key('move_destination__sub')
      } else if (this.activeOverlay === 'sort') {
        Text('Sort notebook').fontSize(18).padding(16)
        Button('Name A-Z').key('sort_name_ascending')
        Button('Modified newest').key('sort_modified_descending')
      } else if (this.activeOverlay === 'goto') {
        Text('Go to').fontSize(18).padding(16)
        ForEach(['Notebook', 'Favourites', 'Recent', 'Popular'], (name: string) => {
          Button(name).key('virtual_folder__' + name.toLowerCase())
            .onClick(() => {
              this.activeOverlay = '';
            })
        }, (name: string) => name)
      } else if (this.activeOverlay === 'todo_complete') {
        Text('Completion').fontSize(18).padding(16)
        Text('Mark task complete or active').fontSize(14).padding({ left: 16, right: 16 })
        Button('Toggle completion').key('todotxt_toggle_completion')
          .onClick(() => { this.todoActionChoice = 'completion'; })
      } else if (this.activeOverlay === 'todo_priority') {
        Text('Priority').fontSize(18).padding(16)
        Row({ space: 8 }) {
          ForEach(['A', 'B', 'C'], (priority: string) => {
            Button(priority).key('todotxt_priority__' + priority)
              .onClick(() => { this.todoActionChoice = priority; })
          }, (priority: string) => priority)
        }.padding({ left: 16, right: 16 })
        Button('Clear priority').key('todotxt_clear_priority')
          .onClick(() => { this.todoActionChoice = 'clear'; }).margin(16)
      } else if (this.activeOverlay === 'todo_due_date') {
        Text('Due date').fontSize(18).padding(16)
        TextInput({ placeholder: 'YYYY-MM-DD' }).id('todo_shell_due_date_input')
          .onChange((value: string) => { this.todoActionChoice = value; })
          .margin({ left: 16, right: 16 })
        Button('Clear due date').key('todotxt_clear_due')
          .onClick(() => { this.todoActionChoice = 'clear'; }).margin(16)
      } else if (this.activeOverlay === 'todo_sort') {
        Text('Sort tasks').fontSize(18).padding(16)
        ForEach(['Priority', 'Due date', 'Alphabetical'], (criterion: string) => {
          Button(criterion).key('todotxt_sort__' + criterion.toLowerCase().replace(' ', '_'))
            .onClick(() => { this.todoActionChoice = criterion; })
        }, (criterion: string) => criterion)
      } else if (this.activeOverlay === 'todo_context') {
        Text('Add context').fontSize(18).padding(16)
        ForEach(['home', 'shop'], (context: string) => {
          Button(context).key('todotxt_context__' + context)
            .onClick(() => { this.todoActionChoice = context; })
        }, (context: string) => context)
      } else if (this.activeOverlay === 'todo_project') {
        Text('Add project').fontSize(18).padding(16)
        ForEach(['shopping', 'family', 'reading', 'work', 'travel', 'music', 'video'], (project: string) => {
          Button(project).key('todotxt_project__' + project)
            .onClick(() => { this.todoActionChoice = project; })
        }, (project: string) => project)
      } else if (this.activeOverlay === 'todo_archive') {
        Text('Archive completed tasks').fontSize(18).padding(16)
        Text('Completed tasks remain unchanged in this presentation-only shell.')
          .fontSize(14).padding({ left: 16, right: 16 })
      }
      if (this.activeOverlay !== 'goto') {
        Row({ space: 8 }) {
          Button('CANCEL').key('dialog_cancel').onClick(() => {
            // Delete keeps the pre-existing shell behavior; all To-Do menus
            // always close without modifying their presentation seed.
            if (this.activeOverlay !== 'delete') {
              this.activeOverlay = '';
            }
          })
          if (this.activeOverlay === 'delete') {
            Button('DELETE').key('dialog_confirm_delete').onClick(() => { this.activeOverlay = ''; })
          } else if (this.activeOverlay === 'rename') {
            Button('RENAME').key('dialog_confirm_rename').onClick(() => { this.activeOverlay = ''; })
          } else if (this.activeOverlay === 'move') {
            Button('MOVE').key('dialog_confirm_move').onClick(() => { this.activeOverlay = ''; })
          } else if (this.activeOverlay.startsWith('todo_')) {
            // Confirmation is visual-only: do not mutate the editor seed.
            Button('OK').key('todotxt_action_ok').onClick(() => { this.activeOverlay = ''; })
          }
        }.padding(12).width('100%').justifyContent(FlexAlign.End)
      }
    }
    .width('88%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#E0E0E0' })
    .key('notebook_action_dialog')
  }

  build() {
    Stack() {
      Column() {
        if (this.curTab === TAB.NOTEBOOK) {
          this.buildNotebookTab()
        } else if (this.curTab === TAB.TODO) {
          this.editorTab(SEED_TODO_TEXT, true)
        } else if (this.curTab === TAB.QUICKNOTE) {
          this.editorTab(this.quickNote, false)
        } else {
          this.buildMoreTab()
        }
        Row() {
          this.navItem('Notebook', $r('app.media.ic_folder_white_24dp'), 'nav_notebook', TAB.NOTEBOOK)
          this.navItem('To-Do', $r('app.media.ic_assignment_turned_in_black_24dp'), 'nav_todo', TAB.TODO)
          this.navItem('QuickNote', $r('app.media.ic_lightning_black_24dp'), 'nav_quicknote', TAB.QUICKNOTE)
          this.navItem('More', $r('app.media.ic_favorite_black_24dp'), 'nav_more', TAB.MORE)
        }.width('100%').height(56).backgroundColor('#1E2135').id('bottom_navigation_bar')
      }.width('100%').height('100%')

      if (this.nfdVisible) {
        Column() {}.width('100%').height('100%').backgroundColor('rgba(0,0,0,0.4)')
        NewFileDialog({
          visible: this.nfdVisible,
          onCancel: () => { this.nfdVisible = false; },
          onOk: () => { this.nfdVisible = false; },
        })
      }
      if (this.activeOverlay.length > 0) {
        Column() {}.width('100%').height('100%').backgroundColor('rgba(0,0,0,0.4)')
        this.actionDialog()
      }
    }.width('100%').height('100%').backgroundColor('#FAFAFA')
  }
}
