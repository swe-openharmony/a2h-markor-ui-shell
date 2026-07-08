/**
 * ActionButtonSettingsPage — reorder / enable ActionButtons per format.
 *
 * Mirrors Android ActionButtonSettingsActivity. Each row has a drag handle
 * (ao_row_drag_<key>) and a switch (ao_row_switch_<key>). Reset key per labels.
 */
import { ROUTE } from '../model/AppModel';
import router from '@ohos.router';

class ActionRow {
  key: string = '';
  label: string = '';
  enabled: boolean = false;
}
function row(key: string, label: string, enabled: boolean): ActionRow {
  const r: ActionRow = new ActionRow();
  r.key = key; r.label = label; r.enabled = enabled;
  return r;
}

@Entry
@Component
struct ActionButtonSettingsPage {
  @State actions: ActionRow[] = [
    row('abid_markdown_h1', 'Heading 1', true),
    row('abid_markdown_h2', 'Heading 2', true),
    row('abid_markdown_bold', 'Bold', true),
    row('abid_markdown_italic', 'Italic', true),
    row('abid_markdown_strikeout', 'Strike out', false),
    row('abid_markdown_code_inline', 'Inline code', true),
    row('abid_markdown_quote', 'Quote', false),
    row('abid_markdown_horizontal_line', 'Horizontal line', false),
    row('abid_common_unordered_list_char', 'Unordered list', true),
    row('abid_common_ordered_list_number', 'Ordered list', true),
    row('abid_common_checkbox_list', 'Check list', false),
    row('abid_common_time', 'Date and time', true),
    row('abid_common_special_key', 'Special Key', false),
  ];

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_arrow_back_white_24dp')).width(28).height(28).fillColor('#FFFFFF')
          .margin({ left: 8, right: 8 }).onClick(() => router.back())
        Text($r('app.string.actionbutton')).fontSize(20).fontColor('#FFFFFF').layoutWeight(1)
        Text('Reset').fontColor('#FFFFFF').fontSize(14).margin({ right: 16 }).key('action_reorder_reset')
      }.width('100%').height(56).backgroundColor('#1E2135').alignItems(VerticalAlign.Center)

      Text($r('app.string.action_order')).fontSize(13).fontColor('#1976D2')
        .width('100%').padding({ left: 16, top: 12, bottom: 8 })

      List() {
        ForEach(this.actions, (a: ActionRow, idx?: number) => {
          ListItem() {
            Row() {
              Image($r('app.media.ic_drag_handle_black_24dp')).width(24).height(24).fillColor('#9E9E9E')
                .key('ao_row_drag_' + a.key)
              Text(a.label).fontSize(15).layoutWeight(1).margin({ left: 12 })
              Toggle({ type: ToggleType.Switch, isOn: a.enabled })
                .key('ao_row_switch_' + a.key)
                .onChange((on: boolean) => { if (idx !== undefined) { this.actions[idx].enabled = on; } })
            }.width('100%').padding({ left: 16, right: 16, top: 10, bottom: 10 })
          }
        }, (a: ActionRow) => a.key)
      }.layoutWeight(1).divider({ strokeWidth: 1, color: '#F0F0F0' })
    }.width('100%').height('100%').backgroundColor('#FFFFFF')
  }
}
