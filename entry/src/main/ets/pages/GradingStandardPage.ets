// entry/src/main/ets/pages/GradingStandardPage.ets
import router from '@ohos.router';
import { gradingStandardService, GradingCriterion } from '../service/GradingStandardService';

@Entry
@Component
struct GradingStandardPage {
  @State criteria: GradingCriterion[] = [];
  @State newCriterionName: string = '';
  @State newCriterionDescription: string = '';
  @State newCriterionMaxScore: number = 0;
  @State newCriterionWeight: number = 0;
  @State totalWeight: number = 100;
  
  // 编辑模式相关状态
  @State isEditMode: boolean = false;
  @State editingCriterionId: string = '';
  
  // 加载状态
  @State isLoading: boolean = false;
  @State assignmentId: string = '1'; // 使用数字1对应数据库的assignment_id=1
  
  aboutToAppear() {
    console.log('🚀 GradingStandardPage 页面加载');
    this.loadGradingStandard();
  }

  build() {
    Column({ space: 0 }) {
      // 标题栏
      Row({ space: 10 }) {
        Text('←')
          .fontSize(24)
          .fontColor('#1890FF')
          .onClick(() => {
            router.back();
          })
          .margin({ right: 12 })
        Text('评分标准管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(Color.White)

      // 主要内容
      Scroll() {
        Column({ space: 20 }) {
          // 加载状态
          if (this.isLoading) {
            Row() {
              LoadingProgress()
                .width(40)
                .height(40)
                .color('#1890FF')
              Text('加载中...')
                .fontSize(16)
                .margin({ left: 10 })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding(40)
          } else {
            // 评分标准列表
            this.buildCriteriaList()

            // 添加新标准
            this.buildAddCriterionForm()

            // 总权重提示
            this.buildWeightInfo()
          }
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
              .onClick(() => {
                this.editCriterion(criterion);
              })
            Button('删除', { type: ButtonType.Normal })
              .fontSize(14)
              .backgroundColor(Color.Red)
              .onClick(() => {
                this.deleteCriterion(criterion.criterionId);
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
      Text(this.isEditMode ? '编辑评分标准' : '添加新评分标准')
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
        TextInput({ placeholder: '满分', text: this.newCriterionMaxScore > 0 ? this.newCriterionMaxScore.toString() : '' })
          .width(80)
          .type(InputType.Number)
          .onChange((value: string) => {
            this.newCriterionMaxScore = parseInt(value) || 0;
          })
        Text('权重:')
        TextInput({ placeholder: '权重%', text: this.newCriterionWeight > 0 ? this.newCriterionWeight.toString() : '' })
          .width(80)
          .type(InputType.Number)
          .onChange((value: string) => {
            this.newCriterionWeight = parseInt(value) || 0;
          })
      }
      .width('100%')

      Row({ space: 10 }) {
        Button(this.isEditMode ? '更新标准' : '添加标准', { type: ButtonType.Normal })
          .layoutWeight(1)
          .fontSize(16)
          .backgroundColor(Color.Blue)
          .enabled(this.newCriterionName.length > 0 && this.newCriterionDescription.length > 0 && this.newCriterionMaxScore > 0)
          .onClick(() => {
            if (this.isEditMode) {
              this.updateCriterion();
            } else {
              this.addNewCriterion();
            }
          })
        
        if (this.isEditMode) {
          Button('取消', { type: ButtonType.Normal })
            .fontSize(16)
            .backgroundColor(Color.Gray)
            .onClick(() => {
              this.cancelEdit();
            })
        }
      }
      .width('100%')
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
  
  // ========== 后端交互方法 ==========
  
  /**
   * 从后端加载评分标准
   */
  async loadGradingStandard() {
    try {
      this.isLoading = true;
      console.log(`🔍 加载评分标准: assignmentId=${this.assignmentId}`);
      console.log(`📌 请求URL: /api/v1/grading/assignment/${this.assignmentId}/grading-standard`);
      
      const data = await gradingStandardService.getGradingStandard(this.assignmentId);
      console.log(`📦 后端返回数据:`, JSON.stringify(data));
      
      if (data && data.length > 0) {
        this.criteria = data;
        console.log(`✅ 成功加载 ${data.length} 个评分标准`);
        console.log('📄 评分项列表:', data.map(c => `${c.name}(${c.maxScore}分, ${c.weight}%)`).join(', '));
      } else {
        console.log('⚠️ 后端没有评分标准，使用默认数据');
        // 如果后端没有数据，使用默认数据
        this.criteria = this.getDefaultCriteria();
      }
    } catch (error) {
      console.error('❌ 加载评分标准失败:', error);
      // 加载失败时使用默认数据
      this.criteria = this.getDefaultCriteria();
    } finally {
      this.isLoading = false;
    }
  }
  
  /**
   * 保存到后端
   */
  async saveToBackend() {
    try {
      this.isLoading = true;
      console.log('保存评分标准到后端...');
      
      // 确保所有标准都有assignmentId
      const criteriaToSave: GradingCriterion[] = this.criteria.map((c): GradingCriterion => {
        const result: GradingCriterion = {
          criterionId: c.criterionId,
          assignmentId: this.assignmentId,
          name: c.name,
          description: c.description,
          maxScore: c.maxScore,
          weight: c.weight,
          createdTime: c.createdTime
        };
        return result;
      });
      
      const success = await gradingStandardService.saveGradingStandard(criteriaToSave);
      if (success) {
        console.log('✅ 评分标准保存成功');
        // 重新加载以获取后端生成的ID
        await this.loadGradingStandard();
      } else {
        console.error('❌ 保存评分标准失败');
      }
    } catch (error) {
      console.error('❌ 保存评分标准失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  /**
   * 获取默认评分标准
   */
  private getDefaultCriteria(): GradingCriterion[] {
    return [
      {
        assignmentId: this.assignmentId,
        name: '代码质量',
        description: '代码结构清晰，命名规范，注释完整',
        maxScore: 30,
        weight: 30
      },
      {
        assignmentId: this.assignmentId,
        name: '功能实现',
        description: '功能完整，符合需求规格',
        maxScore: 40,
        weight: 40
      },
      {
        assignmentId: this.assignmentId,
        name: '创新性',
        description: '解决方案具有创新性，有独特见解',
        maxScore: 20,
        weight: 20
      },
      {
        assignmentId: this.assignmentId,
        name: '文档质量',
        description: '文档完整，说明清晰',
        maxScore: 10,
        weight: 10
      }
    ];
  }

  private async addNewCriterion() {
    const newCriterion: GradingCriterion = {
      assignmentId: this.assignmentId,
      name: this.newCriterionName,
      description: this.newCriterionDescription,
      maxScore: this.newCriterionMaxScore,
      weight: this.newCriterionWeight || Math.round(100 / (this.criteria.length + 1))
    };

    this.criteria.push(newCriterion);
    this.clearForm();
    console.log('➕ 添加新评分标准，自动保存中...');
    await this.saveToBackend();
  }
  
  private editCriterion(criterion: GradingCriterion) {
    this.isEditMode = true;
    this.editingCriterionId = criterion.criterionId || '';
    this.newCriterionName = criterion.name;
    this.newCriterionDescription = criterion.description;
    this.newCriterionMaxScore = criterion.maxScore;
    this.newCriterionWeight = criterion.weight;
    console.log(`✏️ 编辑评分标准: ${criterion.name}`);
  }
  
  private async updateCriterion() {
    const index = this.criteria.findIndex(c => c.criterionId === this.editingCriterionId);
    if (index !== -1) {
      const original = this.criteria[index];
      this.criteria[index] = {
        criterionId: original.criterionId,
        assignmentId: original.assignmentId,
        name: this.newCriterionName,
        description: this.newCriterionDescription,
        maxScore: this.newCriterionMaxScore,
        weight: this.newCriterionWeight,
        createdTime: original.createdTime
      };
      console.log(`✅ 更新评分标准，自动保存中...`);
      this.clearForm();
      await this.saveToBackend();
    } else {
      this.clearForm();
    }
  }
  
  private cancelEdit() {
    this.clearForm();
  }
  
  private clearForm() {
    this.isEditMode = false;
    this.editingCriterionId = '';
    this.newCriterionName = '';
    this.newCriterionDescription = '';
    this.newCriterionMaxScore = 0;
    this.newCriterionWeight = 0;
  }

  private async deleteCriterion(criterionId?: string) {
    if (!criterionId) {
      // 如果没有ID（新添加未保存），根据其他属性删除
      console.log('⚠️ 删除未保存的标准');
      return;
    }
    this.criteria = this.criteria.filter(criterion => criterion.criterionId !== criterionId);
    console.log(`🗑️ 删除评分标准，自动保存中...`);
    await this.saveToBackend();
  }
}