// entry/src/main/ets/pages/StudentRecommendationPage.ets

import { Student } from '../model/Student';
import { studentService } from '../service/StudentService';

@Component
struct StudentItem {
  @Prop student: Student;
  @State isRecommended: boolean = false;
  
  aboutToAppear() {
    this.isRecommended = this.student.isRecommended;
  }
  
  async toggleRecommendation() {
    try {
      let result: boolean;
      if (this.isRecommended) {
        result = await studentService.cancelRecommendStudent('T001', this.student.studentId);
      } else {
        result = await studentService.recommendStudent('T001', this.student.studentId, '表现优秀');
      }
      
      if (result) {
        this.isRecommended = !this.isRecommended;
        console.log('推荐状态更新成功');
      }
    } catch (error) {
      console.error('更新推荐状态失败:', error);
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
  
  aboutToAppear() {
    this.loadStudents();
    this.loadRecommendedStudents();
  }
  
  async loadStudents() {
    try {
      this.students = await studentService.getStudents(1);
    } catch (error) {
      console.error('加载学生列表失败:', error);
    }
  }
  
  async loadRecommendedStudents() {
    try {
      this.recommendedStudents = await studentService.getRecommendedStudents('T001');
    } catch (error) {
      console.error('加载推荐学生列表失败:', error);
    }
  }
  
  build() {
    Column() {
      // 顶部导航
      Row() {
        Button('←')
          .type(ButtonType.Normal)
          .width(40)
          .height(40)
          .onClick(() => {
            // 返回上一页
            console.log('返回上一页');
          })
        
        Text('推荐学生')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
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
                StudentItem({ student: student })
                
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
                StudentItem({ student: student })
                
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