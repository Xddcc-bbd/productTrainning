// entry/src/main/ets/components/SubmissionListItem.ets

import { Utils } from '../common/Utils';

interface Submission {
  submissionId: number;
  studentId: string;
  studentName: string;
  submissionTime: string;
  status: string;
  score?: number;
  isTeacherRecommended?: boolean;
}

@Component
export struct SubmissionListItem {
  private submission: Submission = {} as Submission;
  private onItemClick: (submission: Submission) => void = () => {};
  private isSelected: boolean = false;

  build() {
    Row({ space: 10 }) {
      // 选择框（用于批量操作）
      if (this.isSelected !== undefined) {
        Checkbox({ name: 'select', group: 'submission' })
          .select(this.isSelected)
          .onChange((value: boolean) => {
            this.isSelected = value;
          })
      }

      // 学生信息
      Column({ space: 4 }) {
        Text(this.submission.studentName)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Row({ space: 10 }) {
          Text('学号: ' + this.submission.studentId)
            .fontSize(12)
            .fontColor(Color.Gray)
          Text(this.submission.submissionTime)
            .fontSize(12)
            .fontColor(Color.Gray)
        }
      }
      .layoutWeight(1)

      // 评分状态
      if (this.submission.score !== undefined) {
        Column({ space: 2 }) {
          Text(this.submission.score.toString())
            .fontSize(16)
            .fontColor(Utils.getScoreColor(this.submission.score))
            .fontWeight(FontWeight.Bold)
          Text(Utils.getGradeLevel(this.submission.score))
            .fontSize(10)
            .fontColor(Color.Gray)
        }
        .alignItems(HorizontalAlign.End)
      } else {
        Text('待批改')
          .fontSize(12)
          .fontColor(Color.Orange)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#FFF7E6')
          .borderRadius(10)
      }

      // 推荐标记
      if (this.submission.isTeacherRecommended) {
        Text('⭐')
          .fontSize(14)
          .fontColor(Color.Orange)
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.submission.score !== undefined ? '#F8F9FA' : Color.White)
    .border({ width: this.isSelected ? 2 : 0, color: Color.Blue })
    .borderRadius(8)
    .onClick(() => {
      this.onItemClick(this.submission);
    })
  }
}