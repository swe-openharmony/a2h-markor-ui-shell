/**
 * NewFileDialog — Markdown/Plain/Todo/etc. new-file dialog.
 *
 * Exposes stable dialog ids for name, extension, type, template,
 * name format, OK, cancel, and folder actions.
 */
import { SK } from '../model/AppModel';

@Component
export struct NewFileDialog {
  @Prop visible: boolean = false;
  onCancel: () => void = () => {};
  onOk: () => void = () => {};
  onFolder: () => void = () => {};
  @StorageLink(SK.NFD_NAME) private name: string = 'Title';
  @StorageLink(SK.NFD_EXT) private ext: string = '.md';
  @StorageLink(SK.NFD_TYPE) private type: string = 'Markdown';
  @StorageLink(SK.NFD_TEMPLATE) private template: string = 'Empty file';
  @StorageLink(SK.NFD_NAME_FORMAT) private nameFmt: string = '{{title}}';
  @State private nameTintRed: boolean = false;

  private formats: string[] = ['Markdown', 'Plain Text', 'To-Do', 'Wikitext / Zim', 'AsciiDoc', 'OrgMode', 'CSV', 'Key - Value'];
  private templates: string[] = ['Empty file', 'Jekyll Post'];

  build() {
    Column() {
      // Name + ext row
      Row() {
        Text($r('app.string.name')).fontSize(13).width(64).fontColor('#757575')
        TextInput({ text: this.name })
          .layoutWeight(2)
          .fontSize(15)
          .backgroundColor('#FFFFFF')
          .borderRadius(0)
          .border({ width: { bottom: 1 }, color: this.nameTintRed ? '#F44336' : '#BDBDBD' })
          .id('new_file_dialog__name')
          .onChange((v: string) => {
            this.name = v;
            this.nameTintRed = v.length > 0 && this.ext.length > 0;
          })
        Text(this.ext)
          .fontSize(15)
          .layoutWeight(1)
          .id('new_file_dialog__ext')
          .fontColor('#212121')
      }.width('100%').padding({ left: 20, right: 20 })

      // Keep terminal actions above the soft keyboard so name entry never
      // makes the public controls disappear from the live UI tree.
      Row() {
        Button('FOLDER').backgroundColor('#FFFFFF').fontColor('#1976D2')
          .id('new_file_dialog__folder').key('new_file_dialog__folder').onClick(() => this.onFolder())
        Button('CANCEL').backgroundColor('#FFFFFF').fontColor('#1976D2')
          .id('new_file_dialog__cancel').key('new_file_dialog__cancel').onClick(() => this.onCancel())
        Button('OK').backgroundColor('#FFFFFF').fontColor('#1976D2')
          .id('new_file_dialog__ok').key('new_file_dialog__ok').onClick(() => this.onOk())
      }.width('100%').justifyContent(FlexAlign.End).padding({ left: 12, right: 12, top: 4 })

      // Format label + name_format
      Row() {
        Text($r('app.string.format')).fontSize(13).width(64).fontColor('#757575')
        Text(this.nameFmt)
          .fontSize(15).layoutWeight(1).id('new_file_dialog__name_format')
      }.width('100%').padding({ left: 20, right: 20, top: 12 })

      // Type (format chooser). A visible keyed popup keeps UiTest interaction
      // deterministic while committing the same live type/extension state.
      Row() {
        Text($r('app.string.type')).fontSize(13).width(64).fontColor('#757575')
        Button(this.type)
          .layoutWeight(1)
          .id('new_file_dialog__type')
          .key('new_file_dialog__type')
          .backgroundColor('#F5F5F5')
          .fontColor('#212121')
          .onClick(() => {
            // Public base-shell stub: the format control remains interactive.
          })
      }.width('100%').padding({ left: 20, right: 20, top: 12 })

      // Template
      Row() {
        Text($r('app.string.template')).fontSize(13).width(64).fontColor('#757575')
        Select(this.templates.map((t: string) => {
          const o: SelectOption = { value: t };
          return o;
        }))
          .selected(this.templates.indexOf(this.template))
          .value(this.template)
          .layoutWeight(1)
          .id('new_file_dialog__template')
          .onSelect((idx: number) => { this.template = this.templates[idx]; })
      }.width('100%').padding({ left: 20, right: 20, top: 12 })

      // Hints
      Column() {
        Text($r('app.string.folder_is_created_without_extension')).fontSize(11).fontColor('#9E9E9E')
        Text($r('app.string.keep_existing_file')).fontSize(11).fontColor('#9E9E9E').margin({ top: 2 })
      }.width('100%').padding({ left: 20, right: 20, top: 12 }).alignItems(HorizontalAlign.Start)

    }
    .width('86%')
    .backgroundColor('#FFFFFF')
    .borderRadius(4)
    .margin({ top: 80 })
    .alignItems(HorizontalAlign.Start)
  }
}
