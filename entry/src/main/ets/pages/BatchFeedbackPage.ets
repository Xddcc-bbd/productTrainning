// entry/src/main/ets/pages/BatchFeedbackPage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

interface BatchFeedbackTemplate {
  feedbackId: number;
  title: string;
  content: string;
  usedCount: number;
  assignmentId: number;
}

@Entry
@Component
struct BatchFeedbackPage {
  @State templates: BatchFeedbackTemplate[] = [
    {
      feedbackId: 1,
      title: '代码规范问题',
      content: '请注意代码缩进和命名规范，变量名应具有描述性。',
      usedCount: 15,
      assignmentId: 1
    },
    {
      feedbackId: 2,
      title: '逻辑优化建议',
      content: '算法逻辑可以进一步优化，考虑时间复杂度和空间复杂度。',
      usedCount: 8,
      assignmentId: 1
    }
  ];

  @State selectedSubmissions: number[] = [1, 2];
  @State newTemplateTitle: string = '';
  @State newTemplateContent: string = '';

  build() {
    Column({ space: 0 }) {
      // 标题栏
      Row({ space: 10 }) {
        Text('←')  // 使用箭头符号
          .fontSize(24)
          .fontColor(Color.Blue)
          .onClick(() => {
            router.back();
          })
        Text('批量反馈')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })
      .backgroundColor(Color.White)

      // 主要内容
      Scroll() {
        Column({ space: 20 }) {
          // 选择提交区域
          this.buildSubmissionSelection()

          // 反馈模板区域
          this.buildFeedbackTemplates()

          // 新建模板区域
          this.buildNewTemplate()
        }
        .padding(15)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder buildSubmissionSelection() {
    Column({ space: 10 }) {
      Text('选择要批量处理的提交 (已选择 ' + this.selectedSubmissions.length + ' 个)')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)

      Row({ space: 10 }) {
        Button('全选', { type: ButtonType.Normal })
          .fontSize(14)
        Button('选择未批改', { type: ButtonType.Normal })
          .fontSize(14)
        Button('清空选择', { type: ButtonType.Normal })
          .fontSize(14)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  @Builder buildFeedbackTemplates() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        Text('反馈模板')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text('(' + this.templates.length + '个模板)')
          .fontSize(14)
          .fontColor(Color.Gray)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      ForEach(this.templates, (template: BatchFeedbackTemplate) => {
        Column({ space: 8 }) {
          Row({ space: 10 }) {
            Text(template.title)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
            Text('已使用 ' + template.usedCount + ' 次')
              .fontSize(12)
              .fontColor(Color.Gray)
          }
          .width('100%')

          Text(template.content)
            .fontSize(14)
            .fontColor(Color.Gray)
            .width('100%')
            .textAlign(TextAlign.Start)

          Row({ space: 10 }) {
            Button('应用此模板', { type: ButtonType.Normal })
              .fontSize(14)
              .backgroundColor(Color.Blue)
              .onClick(() => {
                this.applyTemplate(template);
              })
            Button('编辑', { type: ButtonType.Normal })
              .fontSize(14)
            Button('删除', { type: ButtonType.Normal })
              .fontSize(14)
              .backgroundColor(Color.Red)
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
        }
        .width('100%')
        .padding(15)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .margin({ bottom: 10 })
      })
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  @Builder buildNewTemplate() {
    Column({ space: 10 }) {
      Text('新建反馈模板')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)

      TextInput({ placeholder: '模板标题', text: this.newTemplateTitle })
        .width('100%')
        .onChange((value: string) => {
          this.newTemplateTitle = value;
        })

      TextInput({ placeholder: '模板内容', text: this.newTemplateContent })
        .width('100%')
        .height(80)
        .onChange((value: string) => {
          this.newTemplateContent = value;
        })

      Button('保存模板', { type: ButtonType.Normal })
        .width('100%')
        .fontSize(16)
        .backgroundColor(Color.Blue)
        .enabled(this.newTemplateTitle.length > 0 && this.newTemplateContent.length > 0)
        .onClick(() => {
          this.saveNewTemplate();
        })
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  private applyTemplate(template: BatchFeedbackTemplate) {
    promptAction.showToast({
      message: `已将"${template.title}"应用到 ${this.selectedSubmissions.length} 个提交`,
      duration: 2000
    });
  }

  private saveNewTemplate() {
    const newTemplate: BatchFeedbackTemplate = {
      feedbackId: Date.now(),
      title: this.newTemplateTitle,
      content: this.newTemplateContent,
      usedCount: 0,
      assignmentId: 1
    };

    this.templates.push(newTemplate);
    this.newTemplateTitle = '';
    this.newTemplateContent = '';

    promptAction.showToast({
      message: '模板保存成功',
      duration: 2000
    });
  }
}