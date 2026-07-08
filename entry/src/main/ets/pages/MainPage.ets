/**
 * MainPage — bottom-nav host (Files / To-Do / QuickNote / More).
 *
 * Mirrors Android MainActivity: ViewPager2 + BottomNavigationView + FAB.
 * NOTEBOOK_*_KEY). NewFileDialog is hosted here per labels.ROUTE_NEW_FILE_DIALOG.
 */
import router from '@ohos.router';
import { SK, TAB, ROUTE, FsEntry, TodoTask } from '../model/AppModel';
import { NewFileDialog } from '../component/NewFileDialog';

@Entry
@Component
struct MainPage {
  @StorageLink(SK.CUR_TAB) private curTab: number = TAB.NOTEBOOK;
  @StorageLink(SK.NOTEBOOK_ENTRIES) private entries: FsEntry[] = [];
  @StorageLink(SK.TODO_TASKS) private tasks: TodoTask[] = [];
  @StorageLink(SK.NEW_FILE_DIALOG_VISIBLE) private nfdVisible: boolean = false;
  @State private searchQuery: string = '';

  @Builder navItem(label: string, icon: Resource, key: string, idx: number) {
    Column() {
      Image(icon).width(24).height(24).fillColor(this.curTab === idx ? '#F04B4B' : '#FFFFFF')
      Text(label)
        .fontSize(12)
        .fontColor(this.curTab === idx ? '#F04B4B' : '#FFFFFF')
        .margin({ top: 4 })
    }
    .key(key)
    .layoutWeight(1)
    .height(56)
    .justifyContent(FlexAlign.Center)
    .onClick(() => { this.curTab = idx; })
  }

  @Builder buildNotebookTab() {
    Column() {
      // Appbar
      Row() {
        Text($r('app.string.app_name')).fontSize(20).fontWeight(FontWeight.Medium).layoutWeight(1).margin({ left: 16 }).fontColor('#FFFFFF')
        Image($r('app.media.ic_baseline_rule_folder_24')).width(28).height(28).fillColor('#FFFFFF').key('action_go_to')
          .onClick(() => {})
        Image($r('app.media.ic_sort_black_24dp')).width(28).height(28).fillColor('#FFFFFF').key('action_sort').margin({ left: 8 })
          .onClick(() => {})
        Image($r('app.media.ic_search_black_24dp')).width(28).height(28).fillColor('#FFFFFF').key('action_search').margin({ left: 8 }).onClick(() => {})
        Image($r('app.media.ic_more_vert_black_24dp')).width(28).height(28).fillColor('#FFFFFF').margin({ left: 8, right: 12 }).onClick(() => {})
      }.width('100%').height(56).backgroundColor('#1E2135').alignItems(VerticalAlign.Center)
       .key('notebook_toolbar_title')

      // File list
      if (this.entries.length === 0) {
        Column() {
          Text($r('app.string.empty_directory')).fontSize(16).fontColor('#9E9E9E')
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 0 }) {
          ForEach(this.entries, (e: FsEntry, i?: number) => {
            ListItem() {
              Row() {
                Image(e.isFolder ? $r('app.media.ic_folder_gray_24dp') : $r('app.media.ic_file_gray_24dp'))
                  .width(28).height(28).fillColor('#757575')
                Column() {
                  Text(e.name).fontSize(16).fontColor('#212121').maxLines(1)
                  Text(e.description).fontSize(12).fontColor('#757575').maxLines(1).margin({ top: 2 })
                }.layoutWeight(1).margin({ left: 12 }).alignItems(HorizontalAlign.Start)
              }
              .width('100%').height(72).padding({ left: 16, right: 16 }).alignItems(VerticalAlign.Center)
              .key('opoc_filesystem_item__root')
              .id('opoc_filesystem_item__title')
              .onClick(() => {
                if (!e.isFolder) {
                  AppStorage.setOrCreate<string>(SK.EDITOR_TITLE, e.name.replace(/\.[^.]+$/, ''));
                  AppStorage.setOrCreate<string>(SK.CUR_ROUTE, ROUTE.EDITOR);
                  router.pushUrl({ url: ROUTE.EDITOR });
                }
              })
            }
          }, (e: FsEntry) => e.name + e.path)
        }.layoutWeight(1).divider({ strokeWidth: 1, color: '#F0F0F0', startMargin: 56, endMargin: 0 })
         .id('ui__filesystem_dialog__list')
      }

      // FAB (notebook tab only)
      if (this.curTab === TAB.NOTEBOOK) {
        Flex({ justifyContent: FlexAlign.End, alignItems: ItemAlign.End }) {
          Column() {
            Image($r('app.media.ic_add_white_24dp')).width(28).height(28).fillColor('#FFFFFF')
          }.width(56).height(56).borderRadius(28).backgroundColor('#F04B4B')
           .margin({ right: 16, bottom: 16 })
           .key('fab_add_new_item')
           .onClick(() => { this.nfdVisible = true; })
        }.width('100%').layoutWeight(0).padding({ bottom: 0 })
      }
    }.width('100%').layoutWeight(1)
  }

  @Builder buildTodoTab() {
    Column() {
      // Appbar: app name + 6 action icons (Undo, Redo, Save, Preview, Search, Overflow) — editor variant
      Row() {
        Text($r('app.string.app_name')).fontSize(20).fontWeight(FontWeight.Medium).layoutWeight(1).margin({ left: 8 }).fontColor('#FFFFFF')
        Image($r('app.media.ic_undo_black_24dp')).width(28).height(28).fillColor('#FFFFFF').margin({ left: 8, right: 8 }).key('action_undo').onClick(() => {})
        Image($r('app.media.ic_redo_black_24dp')).width(28).height(28).fillColor('#FFFFFF').margin({ left: 8, right: 8 }).key('action_redo').onClick(() => {})
        Image($r('app.media.ic_save_black_24dp')).width(28).height(28).fillColor('#FFFFFF').margin({ left: 8, right: 8 }).key('action_save').onClick(() => {})
        Image($r('app.media.ic_visibility_black_24dp')).width(28).height(28).fillColor('#FFFFFF').margin({ left: 8, right: 8 }).key('action_preview').onClick(() => {})
        Image($r('app.media.ic_search_black_24dp')).width(28).height(28).fillColor('#FFFFFF').margin({ left: 8, right: 8 }).key('action_search').onClick(() => {})
        Image($r('app.media.ic_more_vert_black_24dp')).width(28).height(28).fillColor('#FFFFFF').margin({ left: 8, right: 8 }).key('action_overflow').onClick(() => {})
      }.width('100%').height(56).backgroundColor('#1E2135').alignItems(VerticalAlign.Center)
       .key('editor_toolbar_title')

      // Editor area — blank editor canvas to match Android page_todo_01_editor_seeded
      // capture (D2): bind to empty seed; onChange still writes to SK.EDITOR_TEXT.
      Column() {
        TextArea({ text: '' })
          .width('100%').layoutWeight(1)
          .fontSize(15)
          .fontFamily('monospace')
          .backgroundColor('#FFFFFF')
          .borderRadius(0)
          .id('document__fragment__edit__highlighting_editor')
          .onChange((v: string) => AppStorage.setOrCreate<string>(SK.EDITOR_TEXT, v))
      }.layoutWeight(1).width('100%').backgroundColor('#FFFFFF')

      // Text-actions bar: 9 todo action icons (Sort, Priority, Rotate, Toggle done, Time, Special key, Text case, Delete lines, Duplicate)
      Scroll() {
        Row() {
          Column() {
            Image($r('app.media.ic_sort_black_24dp')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_sort').onClick(() => {})
          Column() {
            Image($r('app.media.ic_priority_high_white_24dp')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_priority').onClick(() => {})
          Column() {
            Image($r('app.media.ic_rotate_left_black_24dp')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_rotate').onClick(() => {})
          Column() {
            Image($r('app.media.ic_check_box_black_24dp')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_toggle_done').onClick(() => {})
          Column() {
            Image($r('app.media.ic_access_time_black_24dp')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_time').onClick(() => {})
          Column() {
            Image($r('app.media.ic_keyboard_black_24dp')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_special_key').onClick(() => {})
          Column() {
            Image($r('app.media.ic_text_format_white_24dp')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_text_case').onClick(() => {})
          Column() {
            Image($r('app.media.ic_delete_black_24dp')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_delete_lines').onClick(() => {})
          Column() {
            Image($r('app.media.ic_content_copy_black_24dp')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_duplicate').onClick(() => {})
        }.height(48).alignItems(VerticalAlign.Center)
      }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)
       .width('100%').height(48).backgroundColor('#FAFAFA')
       .border({ width: { top: 1 }, color: '#E0E0E0' })
       .id('document__fragment__edit__text_actions_bar')
    }.width('100%').layoutWeight(1)
  }

  @Builder buildQuickNoteTab() {
    Column() {
      // Appbar: app name + 6 action icons (Undo, Redo, Save, Preview, Search, Overflow)
      Row() {
        Text($r('app.string.app_name')).fontSize(20).fontWeight(FontWeight.Medium).layoutWeight(1).margin({ left: 8 }).fontColor('#FFFFFF')
        Image($r('app.media.ic_undo_black_24dp')).width(28).height(28).fillColor('#FFFFFF').margin({ left: 8, right: 8 }).key('action_undo').onClick(() => {})
        Image($r('app.media.ic_redo_black_24dp')).width(28).height(28).fillColor('#FFFFFF').margin({ left: 8, right: 8 }).key('action_redo').onClick(() => {})
        Image($r('app.media.ic_save_black_24dp')).width(28).height(28).fillColor('#FFFFFF').margin({ left: 8, right: 8 }).key('action_save').onClick(() => {})
        Image($r('app.media.ic_visibility_black_24dp')).width(28).height(28).fillColor('#FFFFFF').margin({ left: 8, right: 8 }).key('action_preview').onClick(() => {})
        Image($r('app.media.ic_search_black_24dp')).width(28).height(28).fillColor('#FFFFFF').margin({ left: 8, right: 8 }).key('action_search').onClick(() => {})
        Image($r('app.media.ic_more_vert_black_24dp')).width(28).height(28).fillColor('#FFFFFF').margin({ left: 8, right: 8 }).key('action_overflow').onClick(() => {})
      }.width('100%').height(56).backgroundColor('#1E2135').alignItems(VerticalAlign.Center)
       .key('editor_toolbar_title')

      // Editor area — flat full-width editor, no rounded card treatment (D2)
      // D1 (page_quicknote_01_seeded): wrap editor in a List/ListItem so the
      // view-tree exposes a List-backed main page container matching Android.
      List() {
        ListItem() {
          TextArea({ text: AppStorage.get<string>(SK.QUICKNOTE_TEXT) })
            .width('100%').height('100%')
            .fontSize(15)
            .backgroundColor('#FFFFFF')
            .borderRadius(0)
            .id('document__fragment__edit__highlighting_editor')
            .onChange((v: string) => AppStorage.setOrCreate<string>(SK.QUICKNOTE_TEXT, v))
        }
      }.layoutWeight(1).width('100%').backgroundColor('#FFFFFF')
       .divider({ strokeWidth: 0, color: '#FFFFFF' })

      // Text-actions bar: 9 format icons (Ordered list, Rotate, Time, Special Key, Unordered list, Inline code, Bold, H2, H1)
      Scroll() {
        Row() {
          Column() {
            Image($r('app.media.ic_format_list_numbered_black_24dp')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_ordered_list').onClick(() => {})
          Column() {
            Image($r('app.media.ic_rotate_left_black_24dp')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_rotate').onClick(() => {})
          Column() {
            Image($r('app.media.ic_access_time_black_24dp')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_time').onClick(() => {})
          Column() {
            Image($r('app.media.ic_keyboard_black_24dp')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_special_key').onClick(() => {})
          Column() {
            Image($r('app.media.ic_format_list_bulleted_black_24dp')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_unordered_list').onClick(() => {})
          Column() {
            Image($r('app.media.ic_code_black_24dp')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_inline_code').onClick(() => {})
          Column() {
            Image($r('app.media.ic_format_bold_black_24dp')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_bold').onClick(() => {})
          Column() {
            Image($r('app.media.format_header_2')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_h2').onClick(() => {})
          Column() {
            Image($r('app.media.format_header_1')).width(24).height(24).fillColor('#424242')
          }.padding({ left: 10, right: 10 }).key('action_h1').onClick(() => {})
        }.height(48).alignItems(VerticalAlign.Center)
      }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)
       .width('100%').height(48).backgroundColor('#FAFAFA')
       .border({ width: { top: 1 }, color: '#E0E0E0' })
       .id('document__fragment__edit__text_actions_bar')
    }.width('100%').layoutWeight(1)
  }

  @Builder buildMoreTab() {
    Column() {
      Row() {
        Text($r('app.string.app_name')).fontSize(20).fontWeight(FontWeight.Medium).layoutWeight(1).margin({ left: 16 }).fontColor('#FFFFFF')
      }.width('100%').height(56).backgroundColor('#1E2135').alignItems(VerticalAlign.Center)
      List({ space: 0 }) {
        // App identity / About row — D3: left app logo, key satisfies MORE.ABOUT control inventory.
        ListItem() {
          Row() {
            Image($r('app.media.ic_launcher')).width(48).height(48).margin({ right: 16 })
            Column() {
              Text('Markor').fontSize(16).fontColor('#212121')
              Text('net.gsantner.markor\nVersion v2.16.1 (163)').fontSize(12).fontColor('#757575').margin({ top: 2 })
            }.layoutWeight(1).alignItems(HorizontalAlign.Start)
          }.width('100%').padding({ left: 16, right: 16, top: 20, bottom: 20 }).alignItems(VerticalAlign.Center)
            .key('pref_key__more_info__about')
        }
        // D3: feedback row with leading icon
        ListItem() {
          Row() {
            Image($r('app.media.ic_bug_report_black_24dp')).width(24).height(24).fillColor('#757575').margin({ right: 16 })
            Column() {
              Text('Do you have a question or a problem?').fontSize(15).fontColor('#212121')
              Text('Give feedback, report bugs or suggest improvements').fontSize(12).fontColor('#757575').margin({ top: 2 })
            }.layoutWeight(1).alignItems(HorizontalAlign.Start)
          }.width('100%').padding({ left: 16, right: 16, top: 18, bottom: 18 }).alignItems(VerticalAlign.Center)
            .key('pref_key__more_info__feedback')
        }
        ListItem() {
          Row() {
            Image($r('app.media.ic_settings_black_24dp')).width(24).height(24).fillColor('#757575').margin({ right: 16 })
            Text('Settings').fontSize(15).layoutWeight(1)
          }.width('100%').padding({ left: 16, right: 16, top: 18, bottom: 18 }).alignItems(VerticalAlign.Center)
            .key('pref_key__more_info__settings').onClick(() => {
              AppStorage.setOrCreate<string>(SK.CUR_ROUTE, ROUTE.SETTINGS);
              router.pushUrl({ url: ROUTE.SETTINGS });
            })
        }
        ListItem() {
          Row() {
            Image($r('app.media.ic_info_black_24dp')).width(24).height(24).fillColor('#757575').margin({ right: 16 })
            Text('Help / FAQ').fontSize(15).layoutWeight(1)
          }.width('100%').padding({ left: 16, right: 16, top: 18, bottom: 18 }).alignItems(VerticalAlign.Center)
            .key('pref_key__more_info__help_faq')
        }
        ListItem() {
          Row() {
            Image($r('app.media.ic_thumb_up_black_24dp')).width(24).height(24).fillColor('#757575').margin({ right: 16 })
            Text('Rate this app').fontSize(15).layoutWeight(1)
          }.width('100%').padding({ left: 16, right: 16, top: 18, bottom: 18 }).alignItems(VerticalAlign.Center)
            .key('pref_key__more_info__rate')
        }
        // D4/D5: Project Team section — header + contributor row
        ListItem() {
          Column() {
            Text('Project Team').fontSize(13).fontColor('#1976D2').padding({ left: 16, top: 16, bottom: 8 })
          }.width('100%').alignItems(HorizontalAlign.Start)
        }
        ListItem() {
          Row() {
            Image($r('app.media.ic_person_black_24dp')).width(24).height(24).fillColor('#757575').margin({ right: 16 })
            Column() {
              Text('Gregor Santner (gsantner)').fontSize(15).fontColor('#212121')
              Text('Austrian software developer and Open Source enthusiast').fontSize(12).fontColor('#757575').margin({ top: 2 })
            }.layoutWeight(1).alignItems(HorizontalAlign.Start)
          }.width('100%').padding({ left: 16, right: 16, top: 18, bottom: 18 }).alignItems(VerticalAlign.Center)
            .key('pref_key__more_info__contributor_gsantner')
        }
        // Below-the-fold rows — taller padding (D1) keeps them out of the first viewport.
        ListItem() {
          Row() {
            Image($r('app.media.ic_file_gray_24dp')).width(24).height(24).fillColor('#757575').margin({ right: 16 })
            Text($r('app.string.changelog')).fontSize(15).layoutWeight(1)
          }.width('100%').padding({ left: 16, right: 16, top: 18, bottom: 18 }).alignItems(VerticalAlign.Center)
            .key('pref_key__more_info__copy_build_information')
        }
        ListItem() {
          Row() {
            Image($r('app.media.ic_file_gray_24dp')).width(24).height(24).fillColor('#757575').margin({ right: 16 })
            Text($r('app.string.project_license')).fontSize(15).layoutWeight(1)
          }.width('100%').padding({ left: 16, right: 16, top: 18, bottom: 18 }).alignItems(VerticalAlign.Center)
            .key('pref_key__more_info__project_license')
        }
        ListItem() {
          Row() {
            Image($r('app.media.ic_file_gray_24dp')).width(24).height(24).fillColor('#757575').margin({ right: 16 })
            Text($r('app.string.open_source_licenses')).fontSize(15).layoutWeight(1)
          }.width('100%').padding({ left: 16, right: 16, top: 18, bottom: 18 }).alignItems(VerticalAlign.Center)
            .key('pref_key__more_info__open_source_licenses')
        }
        ListItem() {
          Row() {
            Image($r('app.media.ic_file_gray_24dp')).width(24).height(24).fillColor('#757575').margin({ right: 16 })
            Text($r('app.string.contributors')).fontSize(15).layoutWeight(1)
          }.width('100%').padding({ left: 16, right: 16, top: 18, bottom: 18 }).alignItems(VerticalAlign.Center)
            .key('pref_key__more_info__contributors_public_info')
        }
      }.layoutWeight(1).divider({ strokeWidth: 1, color: '#F0F0F0' })
    }.width('100%').layoutWeight(1)
  }

  build() {
    Stack() {
      // Base layer: tab content + bottom nav
      Column() {
        // Tab content
        if (this.curTab === TAB.NOTEBOOK) {
          this.buildNotebookTab()
        } else if (this.curTab === TAB.TODO) {
          this.buildTodoTab()
        } else if (this.curTab === TAB.QUICKNOTE) {
          this.buildQuickNoteTab()
        } else {
          this.buildMoreTab()
        }

        // Bottom navigation bar
        Row() {
          this.navItem('Files', $r('app.media.ic_folder_white_24dp'), 'nav_notebook', TAB.NOTEBOOK)
          this.navItem('To-Do', $r('app.media.ic_assignment_turned_in_black_24dp'), 'nav_todo', TAB.TODO)
          this.navItem('QuickNote', $r('app.media.ic_lightning_black_24dp'), 'nav_quicknote', TAB.QUICKNOTE)
          this.navItem('More', $r('app.media.ic_favorite_black_24dp'), 'nav_more', TAB.MORE)
        }.width('100%').height(56).backgroundColor('#1E2135')
         .border({ width: { top: 1 }, color: '#E0E0E0' })
         .id('bottom_navigation_bar')
      }.width('100%').height('100%')

      // Overlay layer: dim scrim + NewFileDialog as a true full-screen modal (D4)
      if (this.nfdVisible) {
        Column() {
        }.width('100%').height('100%').backgroundColor('rgba(0,0,0,0.4)')
        NewFileDialog({ visible: this.nfdVisible, onCancel: () => { this.nfdVisible = false; }, onOk: () => { this.nfdVisible = false; } })
      }
    }.width('100%').height('100%').backgroundColor('#FAFAFA')
  }
}
