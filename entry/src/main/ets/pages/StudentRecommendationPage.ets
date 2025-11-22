// entry/src/main/ets/pages/StudentRecommendationPage.ets

import { Student } from '../model/Student';
import { studentService } from '../service/StudentService';
import { assignmentService } from '../service/AssignmentService';
import { Assignment } from '../model/Assignment';
import router from '@ohos.router';

@Component
struct StudentItem {
  @Prop student: Student;
  @State isRecommended: boolean = false;
  onRecommendationChanged: () => void = () => {};
  
  aboutToAppear() {
    this.isRecommended = this.student.isRecommended;
  }
  
  async toggleRecommendation() {
    try {
      let result: boolean;
      if (this.isRecommended) {
        result = await studentService.cancelRecommendStudent('teacher_zhao', this.student.studentId);
      } else {
        result = await studentService.recommendStudent('teacher_zhao', this.student.studentId, '表现优秀');
      }
      
      if (result) {
        this.isRecommended = !this.isRecommended;
        console.log('✅ 推荐状态更新成功');
        // 通知父组件刷新
        this.onRecommendationChanged();
      }
    } catch (error) {
      console.error('❌ 更新推荐状态失败:', error);
    }
  }
  
  build() {
    Row() {
      // 学生头像（模拟）
      Row()
        .width(50)
        .height(50)
        .borderRadius(25)
        .backgroundColor('#1890FF')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .margin({ right: 12 })
      
      Column() {
        Row() {
          Text(this.student.realName)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
          
          Blank()
          
          // 条件渲染推荐标签
          if (this.isRecommended) {
            Text('已推荐')
              .fontSize(12)
              .backgroundColor('#52C41A')
              .padding({ left: 8, right: 8 })
              .borderRadius(4)
              .fontColor(Color.White)
          }
        }
        .width('100%')
        
        Text(this.student.className + ' | ' + this.student.major)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
        
        Row() {
          Text('总分: ' + this.student.totalScore)
            .fontSize(12)
            .fontColor('#333333')
          
          Text('排名: ' + this.student.ranking)
            .fontSize(12)
            .fontColor('#333333')
            .margin({ left: 16 })
          
          Text('完成率: ' + this.student.completionRate + '%')
            .fontSize(12)
            .fontColor('#333333')
            .margin({ left: 16 })
        }
        .width('100%')
        .margin({ top: 4 })
      }
      .layoutWeight(1)
      
      // 推荐按钮
      Button(this.isRecommended ? '取消推荐' : '推荐')
        .type(this.isRecommended ? ButtonType.Normal : ButtonType.Capsule)
        .backgroundColor(this.isRecommended ? '#F5F5F5' : '#1890FF')
        .fontColor(this.isRecommended ? '#333333' : '#FFFFFF')
        .fontSize(12)
        .onClick(() => {
          this.toggleRecommendation();
        })
    }
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
  }
}

@Entry
@Component
struct StudentRecommendationPage {
  @State students: Student[] = [];
  @State recommendedStudents: Student[] = [];
  @State showAllStudents: boolean = true;
  @State isLoading: boolean = false;
  @State assignments: Assignment[] = [];
  @State selectedAssignmentId: string = '';
  
  aboutToAppear() {
    this.loadAssignments();
    this.loadStudents();
    this.loadRecommendedStudents();
  }
  
  async loadAssignments() {
    try {
      console.log('加载作业列表...');
      this.assignments = await assignmentService.getTeacherAssignments('teacher_zhao');
      if (this.assignments.length > 0) {
        this.selectedAssignmentId = this.assignments[0].assignmentId;
      }
      console.log(`✅ 加载到 ${this.assignments.length} 个作业`);
    } catch (error) {
      console.error('加载作业列表失败:', error);
    }
  }
  
  async loadStudents() {
    try {
      this.isLoading = true;
      console.log('加载学生列表...');
      // 加载课程学生，这里使用courseId='course_01'
      this.students = await studentService.getStudents('course_01');
      console.log(`✅ 加载到 ${this.students.length} 个学生`);
    } catch (error) {
      console.error('❌ 加载学生列表失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  async loadRecommendedStudents() {
    try {
      console.log('加载推荐学生列表...');
      this.recommendedStudents = await studentService.getRecommendedStudents('teacher_zhao');
      console.log(`✅ 加载到 ${this.recommendedStudents.length} 个推荐学生`);
    } catch (error) {
      console.error('❌ 加载推荐学生列表失败:', error);
    }
  }
  
  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#1890FF')
          .onClick(() => {
            router.back();
          })
          .margin({ right: 12 })
        
        Text('推荐学生')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
        
        Blank()
      }
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      
      // 统计信息
      Row() {
        Column() {
          Text(this.students.length.toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          Text('总学生数')
            .fontSize(12)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        
        Column() {
          Text(this.recommendedStudents.length.toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          Text('已推荐')
            .fontSize(12)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .margin({ left: 16, right: 16, bottom: 16 })
      
      // 切换显示
      Row() {
        Button('所有学生')
          .type(this.showAllStudents ? ButtonType.Capsule : ButtonType.Normal)
          .backgroundColor(this.showAllStudents ? '#1890FF' : '#F5F5F5')
          .fontColor(this.showAllStudents ? '#FFFFFF' : '#333333')
          .layoutWeight(1)
          .margin({ right: 8 })
          .onClick(() => {
            this.showAllStudents = true;
          })
        
        Button('已推荐学生')
          .type(!this.showAllStudents ? ButtonType.Capsule : ButtonType.Normal)
          .backgroundColor(!this.showAllStudents ? '#1890FF' : '#F5F5F5')
          .fontColor(!this.showAllStudents ? '#FFFFFF' : '#333333')
          .layoutWeight(1)
          .margin({ left: 8 })
          .onClick(() => {
            this.showAllStudents = false;
            // 切换到已推荐时，重新加载推荐列表
            this.loadRecommendedStudents();
          })
      }
      .padding({ left: 16, right: 16 })
      
      // 学生列表
      List() {
        // 条件渲染学生列表
        if (this.showAllStudents) {
          ForEach(this.students, (student: Student, index: number) => {
            ListItem() {
              Column() {
                StudentItem({ 
                  student: student,
                  onRecommendationChanged: () => {
                    // 推荐状态变化后，重新加载数据
                    this.loadRecommendedStudents();
                  }
                })
                
                Divider()
                  .color('#EEEEEE')
                  .strokeWidth(1)
              }
            }
          }, (item: Student, index: number) => {
            return item.studentId;
          })
        } else {
          ForEach(this.recommendedStudents, (student: Student, index: number) => {
            ListItem() {
              Column() {
                StudentItem({ 
                  student: student,
                  onRecommendationChanged: () => {
                    // 推荐状态变化后，重新加载数据
                    this.loadRecommendedStudents();
                  }
                })
                
                Divider()
                  .color('#EEEEEE')
                  .strokeWidth(1)
              }
            }
          }, (item: Student, index: number) => {
            return item.studentId;
          })
        }
      }
      .layoutWeight(1)
      .divider({ strokeWidth: 0 })
      .margin({ top: 16 })
    }
  }
}