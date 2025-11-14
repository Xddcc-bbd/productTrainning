import router from '@ohos.router';

/**
 * 积木作品预览页面
 */
@Entry
@Component
struct WorkPreviewPage {
  @State workUrl: string = '';
  @State zoomLevel: number = 1.0;
  @State showAnnotations: boolean = true;

  aboutToAppear() {
    const params = router.getParams() as Record<string, string | number | boolean>;
    if (params && params['workUrl']) {
      this.workUrl = params['workUrl'] as string;
    }
  }

  /**
   * 缩放
   */
  zoomIn() {
    this.zoomLevel = Math.min(this.zoomLevel + 0.2, 3.0);
  }

  zoomOut() {
    this.zoomLevel = Math.max(this.zoomLevel - 0.2, 0.5);
  }

  resetZoom() {
    this.zoomLevel = 1.0;
  }

  build() {
    Column() {
      // 顶部工具栏
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#FFFFFF')
          .onClick(() => {
            router.back();
          })

        Text('积木作品预览')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .margin({ left: 12 })

        Row() {
          Button('缩小')
            .type(ButtonType.Normal)
            .fontSize(12)
            .height(28)
            .margin({ right: 4 })
            .onClick(() => {
              this.zoomOut();
            })

          Button('重置')
            .type(ButtonType.Normal)
            .fontSize(12)
            .height(28)
            .margin({ right: 4 })
            .onClick(() => {
              this.resetZoom();
            })

          Button('放大')
            .type(ButtonType.Normal)
            .fontSize(12)
            .height(28)
            .onClick(() => {
              this.zoomIn();
            })
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 作品预览区域
      Scroll() {
        Column() {
          // 作品展示区域
          Stack() {
            // 作品内容（这里用占位图代替，实际应该是积木作品的渲染）
            Column() {
              Text('📦')
                .fontSize(120)
                .margin({ bottom: 16 })

              Text('积木作品预览')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .margin({ top: 16 })

              Text('实际实现中，这里应该渲染积木作品的3D模型或2D图形')
                .fontSize(12)
                .fontColor('#CCCCCC')
                .margin({ top: 8 })
                .textAlign(TextAlign.Center)
                .padding({ left: 16, right: 16 })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .scale({ x: this.zoomLevel, y: this.zoomLevel })
            .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))

            // 批注标记（示例）
            if (this.showAnnotations) {
              this.buildAnnotationMarkers()
            }
          }
          .width('100%')
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .scrollable(ScrollDirection.Vertical)

      // 底部操作栏
      Row() {
        Button('添加批注')
          .type(ButtonType.Capsule)
          .fontSize(14)
          .layoutWeight(1)
          .height(44)
          .margin({ right: 8 })
          .backgroundColor('#1890FF')
          .onClick(() => {
            // 添加批注功能
          })

        Button(this.showAnnotations ? '隐藏批注' : '显示批注')
          .type(ButtonType.Normal)
          .fontSize(14)
          .layoutWeight(1)
          .height(44)
          .onClick(() => {
            this.showAnnotations = !this.showAnnotations;
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }

  @Builder
  buildAnnotationMarkers() {
    // 示例批注标记
    Column() {
      // 这里可以添加批注标记点
      // 实际实现中，批注标记应该根据数据动态生成
    }
    .width('100%')
    .height('100%')
  }
}

