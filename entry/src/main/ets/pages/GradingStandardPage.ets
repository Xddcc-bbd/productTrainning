// entry/src/main/ets/pages/GradingStandardPage.ets
import router from '@ohos.router';
import { gradingStandardService, GradingCriterion } from '../service/GradingStandardService';
import { Assignment } from '../model/Assignment';
import { assignmentService } from '../service/AssignmentService';

@Entry
@Component
struct GradingStandardPage {
  @State assignments: Assignment[] = []; // 作业列表
  @State selectedAssignment: Assignment = new Assignment(); // 选中的作业
  @State criteria: GradingCriterion[] = [];
  @State newCriterionName: string = '';
  @State newCriterionMaxScore: number = 0;
  
  // 编辑模式相关状态
  @State isEditMode: boolean = false;
  @State editingCriterionId: string = '';
  
  // 加载状态
  @State isLoading: boolean = false;
  @State assignmentId: string = ''; // 当前选中的作业ID
  
  aboutToAppear() {
    console.log('🚀 GradingStandardPage 页面加载');
    this.loadAssignments();
  }
  
  // 加载作业列表
  async loadAssignments() {
    try {
      this.isLoading = true;
      console.log('📚 加载作业列表...');
      // 使用教师ID获取作业列表
      this.assignments = await assignmentService.getTeacherAssignments('teacher_zhao');
      console.log(`✅ 成功加载 ${this.assignments.length} 个作业`);
      
      if (this.assignments.length > 0) {
        // 默认选中第一个作业
        this.selectedAssignment = this.assignments[0];
        this.assignmentId = this.selectedAssignment.assignmentId;
        console.log(`📌 默认选中作业: ${this.selectedAssignment.assignmentName}`);
        // 加载该作业的评分标准
        this.loadGradingStandard();
      }
    } catch (error) {
      console.error('❌ 加载作业列表失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  // 选择作业
  selectAssignment(assignment: Assignment) {
    console.log(`👆 选择作业: ${assignment.assignmentName}`);
    this.selectedAssignment = assignment;
    this.assignmentId = assignment.assignmentId;
    // 清空当前表单
    this.clearForm();
    // 加载新的评分标准
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
        Text('📋 评分标准管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')

      // 主要内容：左右布局
      Row({ space: 12 }) {
        // 左侧：作业列表
        Column() {
          Text('作业列表')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .padding({ left: 8, top: 10, bottom: 8 })
          
          if (this.isLoading && this.assignments.length === 0) {
            LoadingProgress()
              .width(30)
              .height(30)
              .color('#1890FF')
              .margin({ top: 20 })
          } else {
            List({ space: 6 }) {
              ForEach(this.assignments, (assignment: Assignment) => {
                ListItem() {
                  Column({ space: 3 }) {
                    Text(assignment.assignmentName)
                      .fontSize(12)
                      .fontWeight(this.selectedAssignment.assignmentId === assignment.assignmentId ? FontWeight.Medium : FontWeight.Normal)
                      .fontColor(this.selectedAssignment.assignmentId === assignment.assignmentId ? '#1890FF' : '#333333')
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    
                    Text(`ID: ${assignment.assignmentId}`)
                      .fontSize(10)
                      .fontColor('#AAAAAA')
                  }
                  .width('100%')
                  .padding(8)
                  .backgroundColor(this.selectedAssignment.assignmentId === assignment.assignmentId ? '#E6F7FF' : '#FFFFFF')
                  .borderRadius(6)
                  .border({
                    width: this.selectedAssignment.assignmentId === assignment.assignmentId ? 2 : 0.5,
                    color: this.selectedAssignment.assignmentId === assignment.assignmentId ? '#1890FF' : '#E0E0E0'
                  })
                  .onClick(() => {
                    this.selectAssignment(assignment);
                  })
                }
              }, (item: Assignment) => item.assignmentId)
            }
            .layoutWeight(1)
            .divider({ strokeWidth: 0 })
          }
        }
        .width(120)
        .height('100%')
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .padding(6)
        
        // 右侧：评分标准内容
        Column() {
          if (this.assignmentId) {
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
                }
              }
              .padding(16)
            }
            .layoutWeight(1)
          } else {
            // 未选择作业时的提示
            Column() {
              Text('👈 请先选择一个作业')
                .fontSize(16)
                .fontColor('#999999')
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
          }
        }
        .layoutWeight(1)
        .height('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 12, bottom: 16 })
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder buildCriteriaList() {
    Column({ space: 12 }) {
      Row() {
        Text(`📊 评分标准列表`)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
        
        if (this.criteria.length > 0) {
          Text(`共 ${this.criteria.length} 项`)
            .fontSize(14)
            .fontColor('#999999')
        }
      }
      .width('100%')
      .margin({ bottom: 8 })
      
      if (this.criteria.length === 0) {
        // 空状态提示
        Column({ space: 12 }) {
          Text('📄')
            .fontSize(48)
          Text('该作业还没有评分标准')
            .fontSize(16)
            .fontColor('#666666')
          Text('请在下方添加新的评分标准')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .padding(40)
        .backgroundColor('#FAFAFA')
        .borderRadius(10)
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(this.criteria, (criterion: GradingCriterion) => {
          Column({ space: 8 }) {
            // 标题行：名称 + 分数
            Row({ space: 8 }) {
              Text(criterion.name)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .layoutWeight(1)
              
              Row({ space: 4 }) {
                Text(`${criterion.maxScore}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1890FF')
                Text('分')
                  .fontSize(13)
                  .fontColor('#999999')
              }
              .alignItems(VerticalAlign.Bottom)
            }
            .width('100%')

            // 操作按钮
            Row({ space: 6 }) {
              Button('编辑')
                .fontSize(13)
                .backgroundColor('#1890FF')
                .fontColor('#FFFFFF')
                .borderRadius(4)
                .height(32)
                .padding({ left: 14, right: 14 })
                .onClick(() => {
                  this.editCriterion(criterion);
                })
              Button('删除')
                .fontSize(13)
                .backgroundColor('#FF4D4F')
                .fontColor('#FFFFFF')
                .borderRadius(4)
                .height(32)
                .padding({ left: 14, right: 14 })
                .onClick(() => {
                  // 使用criterionId或name作为标识
                  const identifier = criterion.criterionId || criterion.name;
                  console.log(`🗑️ 点击删除按钮`);
                  console.log(`  criterion.name: ${criterion.name}`);
                  console.log(`  criterion.criterionId: ${criterion.criterionId || '未定义'}`);
                  console.log(`  使用标识符: ${identifier}`);
                  this.deleteCriterion(identifier);
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.End)
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .border({ width: 1, color: '#E8E8E8' })
          .margin({ bottom: 8 })
        })
      }
    }
    .width('100%')
  }

  @Builder buildAddCriterionForm() {
    Column({ space: 15 }) {
      Text(this.isEditMode ? '编辑评分标准' : '添加新评分标准')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)

      TextInput({ placeholder: '标准名称', text: this.newCriterionName || '' })
        .width('100%')
        .onChange((value: string) => {
          this.newCriterionName = value;
        })

      Row({ space: 10 }) {
        Text('满分:')
          .fontSize(14)
        TextInput({ placeholder: '请输入分数', text: this.newCriterionMaxScore > 0 ? this.newCriterionMaxScore.toString() : '' })
          .layoutWeight(1)
          .type(InputType.Number)
          .onChange((value: string) => {
            this.newCriterionMaxScore = parseInt(value) || 0;
          })
      }
      .width('100%')

      Row({ space: 8 }) {
        Button(this.isEditMode ? '保存修改' : '添加标准')
          .layoutWeight(1)
          .fontSize(15)
          .backgroundColor('#1890FF')
          .fontColor('#FFFFFF')
          .borderRadius(6)
          .height(42)
          .enabled(
            !!(this.newCriterionName && this.newCriterionName.trim().length > 0) &&
            this.newCriterionMaxScore > 0
          )
          .onClick(() => {
            if (this.isEditMode) {
              this.updateCriterion();
            } else {
              this.addNewCriterion();
            }
          })
        
        if (this.isEditMode) {
          Button('取消')
            .fontSize(15)
            .backgroundColor('#999999')
            .fontColor('#FFFFFF')
            .borderRadius(6)
            .height(42)
            .padding({ left: 20, right: 20 })
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
      
      // 直接使用后端返回的数据，即使是空数组也没关系
      this.criteria = data;
      
      if (data.length > 0) {
        console.log(`✅ 成功加载 ${data.length} 个评分标准`);
        console.log('📄 评分项列表:', data.map(c => `${c.name}(${c.maxScore}分, ${c.weight}%)`).join(', '));
      } else {
        console.log('🆕 该作业还没有评分标准，可以添加新标准');
      }
    } catch (error) {
      console.error('❌ 加载评分标准失败:', error);
      // 加载失败时设置为空数组
      this.criteria = [];
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
      console.log('💾 保存评分标准到后端...');
      console.log(`  作业ID: ${this.assignmentId}`);
      console.log(`  评分标准数量: ${this.criteria.length}`);
      
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

  private async addNewCriterion() {
    const newCriterion: GradingCriterion = {
      assignmentId: this.assignmentId,
      name: this.newCriterionName,
      description: '',  // 描述为空，不再使用
      maxScore: this.newCriterionMaxScore,
      weight: 0  // 权重设为0，不再使用
    };

    this.criteria.push(newCriterion);
    this.clearForm();
    console.log('➕ 添加新评分标准，自动保存中...');
    await this.saveToBackend();
  }
  
  private editCriterion(criterion: GradingCriterion) {
    this.isEditMode = true;
    // 如果criterionId为undefined，使用name作为临时标识
    this.editingCriterionId = criterion.criterionId || criterion.name;
    this.newCriterionName = criterion.name;
    this.newCriterionMaxScore = criterion.maxScore;
    console.log(`✏️ 编辑评分标准: ${criterion.name}`);
    console.log(`  criterionId: ${criterion.criterionId || '未分配'}`);
    console.log(`  editingCriterionId: ${this.editingCriterionId}`);
  }
  
  private async updateCriterion() {
    console.log(`🔄 开始更新评分标准...`);
    console.log(`  查找ID: ${this.editingCriterionId}`);
    
    // 先尝试通过criterionId查找
    let index = this.criteria.findIndex(c => c.criterionId === this.editingCriterionId);
    
    // 如果没找到，尝试通过name查找（针对新添加未保存的项）
    if (index === -1) {
      index = this.criteria.findIndex(c => c.name === this.editingCriterionId);
      console.log(`  通过name查找，index: ${index}`);
    } else {
      console.log(`  通过criterionId查找，index: ${index}`);
    }
    
    if (index !== -1) {
      const original = this.criteria[index];
      this.criteria[index] = {
        criterionId: original.criterionId,
        assignmentId: this.assignmentId,
        name: this.newCriterionName,
        description: '',  // 描述为空，不再使用
        maxScore: this.newCriterionMaxScore,
        weight: 0,  // 权重设为0，不再使用
        createdTime: original.createdTime
      };
      console.log(`✅ 更新评分标准成功，自动保存中...`);
      this.clearForm();
      await this.saveToBackend();
    } else {
      console.error(`❌ 找不到要更新的评分标准: ${this.editingCriterionId}`);
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
    this.newCriterionMaxScore = 0;
  }

  private async deleteCriterion(criterionId?: string) {
    // 如果criterionId不存在，尝试通过name删除
    if (!criterionId) {
      console.log('⚠️ 删除未保存的标准，使用name匹配');
      // 根据name删除（因为数据库中没有criterionId）
      const beforeCount = this.criteria.length;
      this.criteria = this.criteria.filter(criterion => criterion.name !== this.newCriterionName);
      console.log(`🗑️ 删除后数量: ${beforeCount} -> ${this.criteria.length}`);
      await this.saveToBackend();
      return;
    }
    
    console.log(`🗑️ 开始删除评分标准...`);
    console.log(`  原始 criterionId: ${criterionId}`);
    
    // 先尝试通过criterionId删除
    const beforeCount = this.criteria.length;
    let filtered = this.criteria.filter(criterion => criterion.criterionId !== criterionId);
    
    // 如果没有删除任何项（说明criterionId不匹配），尝试通过name删除
    if (filtered.length === beforeCount) {
      console.log(`  ⚠️ 通过criterionId未找到，尝试使用name匹配`);
      // 找到对应的criterion
      const targetCriterion = this.criteria.find(c => {
        // criterionId可能存储为name值
        return c.name === criterionId || c.criterionId === criterionId;
      });
      
      if (targetCriterion) {
        console.log(`  找到目标项: ${targetCriterion.name}`);
        filtered = this.criteria.filter(criterion => criterion.name !== targetCriterion.name);
      }
    }
    
    this.criteria = filtered;
    console.log(`🗑️ 删除后数量: ${beforeCount} -> ${this.criteria.length}`);
    
    // 保存到后端
    await this.saveToBackend();
  }
}