// entry/src/main/ets/pages/GradingStandardPage.ets
import router from '@ohos.router';

interface GradingCriterion {
  id: number;
  name: string;
  description: string;
  maxScore: number;
  weight: number; // 权重百分比
}

@Entry
@Component
struct GradingStandardPage {
  @State criteria: GradingCriterion[] = [
    {
      id: 1,
      name: '代码质量',
      description: '代码结构清晰，命名规范，注释完整',
      maxScore: 30,
      weight: 30
    },
    {
      id: 2,
      name: '功能实现',
      description: '功能完整，符合需求规格',
      maxScore: 40,
      weight: 40
    },
    {
      id: 3,
      name: '创新性',
      description: '解决方案具有创新性，有独特见解',
      maxScore: 20,
      weight: 20
    },
    {
      id: 4,
      name: '文档质量',
      description: '文档完整，说明清晰',
      maxScore: 10,
      weight: 10
    }
  ];

  @State newCriterionName: string = '';
  @State newCriterionDescription: string = '';
  @State newCriterionMaxScore: number = 0;
  @State totalWeight: number = 100;

  build() {
    Column({ space: 0 }) {
      // 标题栏
      Row({ space: 10 }) {
        Text('←')
          .fontSize(24)
          .fontColor(Color.Blue)
          .onClick(() => {
            router.back();
          })
        Text('评分标准管理')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })
      .backgroundColor(Color.White)

      // 主要内容
      Scroll() {
        Column({ space: 20 }) {
          // 评分标准列表
          this.buildCriteriaList()

          // 添加新标准
          this.buildAddCriterionForm()

          // 总权重提示
          this.buildWeightInfo()
        }
        .padding(15)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder buildCriteriaList() {
    Column({ space: 10 }) {
      Text('评分标准列表')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)

      ForEach(this.criteria, (criterion: GradingCriterion) => {
        Column({ space: 10 }) {
          Row({ space: 10 }) {
            Text(criterion.name)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
            Text(`${criterion.maxScore}分`)
              .fontSize(14)
              .fontColor(Color.Blue)
            Text(`${criterion.weight}%`)
              .fontSize(14)
              .fontColor(Color.Green)
          }
          .width('100%')

          Text(criterion.description)
            .fontSize(14)
            .fontColor(Color.Gray)
            .width('100%')
            .textAlign(TextAlign.Start)

          Row({ space: 10 }) {
            Button('编辑', { type: ButtonType.Normal })
              .fontSize(14)
            Button('删除', { type: ButtonType.Normal })
              .fontSize(14)
              .backgroundColor(Color.Red)
              .onClick(() => {
                this.deleteCriterion(criterion.id);
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
        }
        .width('100%')
        .padding(15)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .margin({ bottom: 10 })
      })
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  @Builder buildAddCriterionForm() {
    Column({ space: 15 }) {
      Text('添加新评分标准')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)

      TextInput({ placeholder: '标准名称', text: this.newCriterionName })
        .width('100%')
        .onChange((value: string) => {
          this.newCriterionName = value;
        })

      TextInput({ placeholder: '标准描述', text: this.newCriterionDescription })
        .width('100%')
        .height(80)
        .onChange((value: string) => {
          this.newCriterionDescription = value;
        })

      Row({ space: 15 }) {
        Text('满分:')
        TextInput({ placeholder: '满分', text: this.newCriterionMaxScore.toString() })
          .width(80)
          .type(InputType.Number)
          .onChange((value: string) => {
            this.newCriterionMaxScore = parseInt(value) || 0;
          })
        Text('权重:')
        TextInput({ placeholder: '权重%', text: '0' })
          .width(80)
          .type(InputType.Number)
          .onChange((value: string) => {
            // 权重处理逻辑可以在这里添加
          })
      }
      .width('100%')

      Button('添加标准', { type: ButtonType.Normal })
        .width('100%')
        .fontSize(16)
        .backgroundColor(Color.Blue)
        .enabled(this.newCriterionName.length > 0 && this.newCriterionDescription.length > 0 && this.newCriterionMaxScore > 0)
        .onClick(() => {
          this.addNewCriterion();
        })
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  @Builder buildWeightInfo() {
    Row({ space: 10 }) {
      Text('总权重:')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
      Text(`${this.calculateTotalWeight()}%`)
        .fontSize(16)
        .fontColor(this.calculateTotalWeight() === 100 ? Color.Green : Color.Red)
        .fontWeight(FontWeight.Bold)

      if (this.calculateTotalWeight() !== 100) {
        Text('(应为100%)')
          .fontSize(14)
          .fontColor(Color.Red)
      }
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  private calculateTotalWeight(): number {
    let total = 0;
    this.criteria.forEach(criterion => {
      total += criterion.weight;
    });
    return total;
  }

  private addNewCriterion() {
    const newCriterion: GradingCriterion = {
      id: Date.now(),
      name: this.newCriterionName,
      description: this.newCriterionDescription,
      maxScore: this.newCriterionMaxScore,
      weight: Math.round(100 / (this.criteria.length + 1))
    };

    this.criteria.push(newCriterion);
    this.newCriterionName = '';
    this.newCriterionDescription = '';
    this.newCriterionMaxScore = 0;
  }

  private deleteCriterion(id: number) {
    this.criteria = this.criteria.filter(criterion => criterion.id !== id);
  }
}