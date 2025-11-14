import { GradingStandard, GradingItem } from '../models/GradingModels';
import { GradingService } from '../utils/GradingService';
import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';

/**
 * 评分标准定义页面
 */
@Entry
@Component
struct GradingStandardPage {
  @State gradingStandard: GradingStandard = new GradingStandard();
  @State isEditing: boolean = false;
  @State editingItem: GradingItem | null = null;
  private standardId: string = '';
  private taskId: string = '';
  private gradingService: GradingService = GradingService.getInstance();

  aboutToAppear() {
    const params = router.getParams() as Record<string, string | number | boolean>;
    if (params) {
      this.standardId = (params['standardId'] as string) || '';
      this.taskId = (params['taskId'] as string) || '';
      this.loadGradingStandard();
    }
  }

  /**
   * 加载评分标准
   */
  async loadGradingStandard() {
    if (this.standardId) {
      const standard = await this.gradingService.getGradingStandard(this.standardId);
      if (standard) {
        this.gradingStandard = standard;
      }
    } else {
      // 新建评分标准
      this.gradingStandard = new GradingStandard();
      this.gradingStandard.taskId = this.taskId;
      this.gradingStandard.name = '新评分标准';
      this.gradingStandard.totalScore = 100;
    }
  }

  /**
   * 添加评分项
   */
  addGradingItem() {
    const newItem: GradingItem = {
      id: `item_${Date.now()}`,
      name: '新评分项',
      description: '',
      score: 0,
      weight: 0
    };
    this.gradingStandard.items.push(newItem);
    this.editItem(newItem);
  }

  /**
   * 编辑评分项
   */
  editItem(item: GradingItem) {
    // ⚠️ 修复 Line 65: 避免使用对象展开 {...item}，改为显式赋值创建副本，符合 arkts-no-spread 规则。
    this.editingItem = {
      id: item.id,
      name: item.name,
      description: item.description,
      score: item.score,
      weight: item.weight
    };
    this.isEditing = true;
  }

  /**
   * 保存评分项
   */
  saveItem() {
    // ⚠️ 修复 Line 77: 将 this.editingItem 赋值给一个本地常量 editedItem，
    // 帮助 ArkTS 编译器进行类型收窄，消除 'Object is possibly 'null'.' 的警告。
    const editedItem = this.editingItem;
    if (!editedItem) {
      return;
    }

    const index = this.gradingStandard.items.findIndex(item => item.id === editedItem.id);
    if (index >= 0) {
      // ⚠️ 修复 Line 79: 避免使用对象展开，改为显式赋值更新数组中的元素。
      this.gradingStandard.items[index] = {
        id: editedItem.id,
        name: editedItem.name,
        description: editedItem.description,
        score: editedItem.score,
        weight: editedItem.weight
      };
    }

    this.calculateWeights();
    this.isEditing = false;
    this.editingItem = null;
  }

  /**
   * 删除评分项
   */
  deleteItem(itemId: string) {
    this.gradingStandard.items = this.gradingStandard.items.filter(item => item.id !== itemId);
    this.calculateWeights();
  }

  /**
   * 计算权重
   */
  calculateWeights() {
    const totalScore = this.gradingStandard.items.reduce((sum, item) => sum + item.score, 0);
    if (totalScore > 0) {
      this.gradingStandard.items.forEach(item => {
        item.weight = item.score / totalScore;
      });
    }
  }

  /**
   * 保存评分标准
   */
  async saveGradingStandard() {
    // 验证总分
    const totalScore = this.gradingStandard.items.reduce((sum, item) => sum + item.score, 0);
    if (Math.abs(totalScore - this.gradingStandard.totalScore) > 0.01) {
      promptAction.showToast({ message: `总分不匹配，当前总分: ${totalScore}` });
      return;
    }

    const success = await this.gradingService.saveGradingStandard(this.gradingStandard);
    if (success) {
      promptAction.showToast({ message: '保存成功' });
      router.back();
    } else {
      promptAction.showToast({ message: '保存失败，请重试' });
    }
  }

  build() {
    Stack() {
      Column() {
        // 顶部工具栏
        Row() {
          Text('←')
            .fontSize(24)
            .fontColor('#000000')
            .onClick(() => {
              router.back();
            })

          Text('评分标准')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#000000')
            .layoutWeight(1)
            .margin({ left: 12 })

          Button('保存')
            .type(ButtonType.Normal)
            .fontSize(14)
            .onClick(() => {
              this.saveGradingStandard();
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')

        Scroll() {
          Column() {
            // 基本信息
            this.buildBasicInfoSection()

            // 评分项列表
            this.buildGradingItemsSection()

            // 添加评分项按钮
            Button('添加评分项')
              .type(ButtonType.Capsule)
              .width('100%')
              .height(44)
              .margin({ top: 16, left: 16, right: 16 })
              .backgroundColor('#1890FF')
              .onClick(() => {
                this.addGradingItem();
              })
          }
          .width('100%')
          .padding({ bottom: 16 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      // 编辑对话框 - 覆盖层
      if (this.isEditing && this.editingItem) {
        Column() {
          Blank()
            .layoutWeight(1)
            .onClick(() => {
              this.isEditing = false;
              this.editingItem = null;
            })

          this.buildEditDialog()

          Blank()
            .layoutWeight(1)
            .onClick(() => {
              this.isEditing = false;
              this.editingItem = null;
            })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#80000000')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildBasicInfoSection() {
    Column() {
      Text('基本信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#000000')
        .margin({ bottom: 16 })

      Column() {
        Row() {
          Text('标准名称:')
            .fontSize(14)
            .fontColor('#666666')
            .width(80)

          TextInput({ placeholder: '请输入标准名称', text: this.gradingStandard.name })
            .layoutWeight(1)
            .height(40)
            .onChange((value: string) => {
              this.gradingStandard.name = value;
            })
        }
        .width('100%')
        .margin({ bottom: 12 })

        Row() {
          Text('总分:')
            .fontSize(14)
            .fontColor('#666666')
            .width(80)

          TextInput({ placeholder: '请输入总分', text: this.gradingStandard.totalScore.toString() })
            .type(InputType.Number)
            .layoutWeight(1)
            .height(40)
            .onChange((value: string) => {
              this.gradingStandard.totalScore = Number.parseInt(value) || 100;
            })
        }
        .width('100%')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .margin({ top: 8, left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder
  buildGradingItemsSection() {
    Column() {
      Row() {
        Text('评分项')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
          .layoutWeight(1)

        Text(`总分: ${this.gradingStandard.items.reduce((sum, item) => sum + item.score, 0)}/${this.gradingStandard.totalScore}`)
          .fontSize(14)
          .fontColor(this.gradingStandard.items.reduce((sum, item) => sum + item.score, 0) === this.gradingStandard.totalScore ? '#52C41A' : '#FF4D4F')
      }
      .width('100%')
      .margin({ bottom: 16 })

      if (this.gradingStandard.items.length === 0) {
        Text('暂无评分项，请添加')
          .fontSize(14)
          .fontColor('#999999')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(32)
      } else {
        Column() {
          ForEach(this.gradingStandard.items, (item: GradingItem) => {
            this.buildGradingItemCard(item)
          })
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .margin({ top: 8, left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder
  buildGradingItemCard(item: GradingItem) {
    Column() {
      Row() {
        Column() {
          Text(item.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#000000')
            .margin({ bottom: 4 })

          if (item.description) {
            Text(item.description)
              .fontSize(12)
              .fontColor('#999999')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column() {
          Text(`${item.score}分`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1890FF')
            .margin({ bottom: 4 })

          Text(`权重: ${(item.weight * 100).toFixed(1)}%`)
            .fontSize(12)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Button('编辑')
          .type(ButtonType.Normal)
          .fontSize(12)
          .height(28)
          .layoutWeight(1)
          .margin({ right: 8 })
          .onClick(() => {
            this.editItem(item);
          })

        Button('删除')
          .type(ButtonType.Normal)
          .fontSize(12)
          .height(28)
          .layoutWeight(1)
          .backgroundColor('#FF4D4F')
          .onClick(() => {
            this.deleteItem(item.id);
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .margin({ bottom: 12 })
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }

  @Builder
  buildEditDialog() {
    // 这里不需要额外的 null 检查，因为外层 if (this.isEditing && this.editingItem) 已经保证了 editingItem 非空
    // 但为了避免潜在的编译警告，最好在内部使用时也保持严谨
    if (this.editingItem) {
      Column() {
        Row() {
          Text('编辑评分项')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#000000')
            .layoutWeight(1)

          Text('×')
            .fontSize(24)
            .fontColor('#999999')
            .onClick(() => {
              this.isEditing = false;
              this.editingItem = null;
            })
        }
        .width('100%')
        .margin({ bottom: 16 })

        Column() {
          Row() {
            Text('名称:')
              .fontSize(14)
              .fontColor('#666666')
              .width(60)

            TextInput({
              placeholder: '请输入评分项名称',
              text: this.editingItem.name
            })
              .layoutWeight(1)
              .height(40)
              .onChange((value: string) => {
                if (this.editingItem) {
                  this.editingItem.name = value;
                }
              })
          }
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Text('描述:')
              .fontSize(14)
              .fontColor('#666666')
              .width(60)

            TextArea({
              placeholder: '请输入评分项描述',
              text: this.editingItem.description
            })
              .layoutWeight(1)
              .height(80)
              .onChange((value: string) => {
                if (this.editingItem) {
                  this.editingItem.description = value;
                }
              })
          }
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Text('分数:')
              .fontSize(14)
              .fontColor('#666666')
              .width(60)

            TextInput({
              placeholder: '请输入分数',
              text: this.editingItem.score.toString()
            })
              .type(InputType.Number)
              .layoutWeight(1)
              .height(40)
              .onChange((value: string) => {
                if (this.editingItem) {
                  this.editingItem.score = Number.parseInt(value) || 0;
                }
              })
          }
          .width('100%')
        }
        .width('100%')
        .margin({ bottom: 16 })

        Row() {
          Button('取消')
            .type(ButtonType.Normal)
            .fontSize(14)
            .layoutWeight(1)
            .height(44)
            .margin({ right: 8 })
            .onClick(() => {
              this.isEditing = false;
              this.editingItem = null;
            })

          Button('确定')
            .type(ButtonType.Capsule)
            .fontSize(14)
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#1890FF')
            .onClick(() => {
              this.saveItem();
            })
        }
        .width('100%')
      }
      .width('90%')
      .padding(24)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({ radius: 20, color: '#000000', offsetX: 0, offsetY: 4 })
    }
  }
}