// entry/src/main/ets/common/Utils.ets

import { Constants } from './Constants';

export class Utils {
  /**
   * 格式化日期时间
   */
  static formatDateTime(date: Date, format: string = 'YYYY-MM-DD HH:mm'): string {
    const year = date.getFullYear();
    // 【修复】不能使用 this.padZero，必须使用类名 Utils.padZero
    const month = Utils.padZero(date.getMonth() + 1);
    const day = Utils.padZero(date.getDate());
    const hours = Utils.padZero(date.getHours());
    const minutes = Utils.padZero(date.getMinutes());
    const seconds = Utils.padZero(date.getSeconds());

    return format
      .replace('YYYY', year.toString())
      .replace('MM', month)
      .replace('DD', day)
      .replace('HH', hours)
      .replace('mm', minutes)
      .replace('ss', seconds);
  }

  /**
   * 补零函数
   */
  private static padZero(num: number): string {
    return num < 10 ? `0${num}` : num.toString();
  }

  /**
   * 计算提交率
   */
  static calculateSubmissionRate(submitted: number, total: number): number {
    if (total === 0) return 0;
    return Math.round((submitted / total) * 100);
  }

  /**
   * 根据分数获取等级
   */
  static getGradeLevel(score: number): string {
    if (score >= 90) return '优秀';
    if (score >= 80) return '良好';
    if (score >= 70) return '中等';
    if (score >= 60) return '及格';
    return '不及格';
  }

  /**
   * 根据分数获取颜色
   * 使用 Constants 中定义的颜色
   */
  static getScoreColor(score: number): string {
    if (score >= 90) return Constants.COLORS.SUCCESS;
    if (score >= 80) return Constants.COLORS.PRIMARY;
    if (score >= 70) return Constants.COLORS.WARNING;
    if (score >= 60) return Constants.COLORS.WARNING;
    return Constants.COLORS.ERROR;
  }

  /**
   * 深拷贝对象
   * 注意：JSON.parse/stringify 是一种简单的深拷贝，适用于无函数、无循环引用的对象
   */
  static deepClone<T>(obj: T): T {
    return JSON.parse(JSON.stringify(obj)) as T;
  }

  /**
   * 防抖函数
   * 【修复】移除 any 和 apply，改为接受无参回调。
   * 如果需要传参，请在调用时使用箭头函数包裹：Utils.debounce(() => myFunc(arg), 500)
   */
  static debounce(func: () => void, delay: number): () => void {
    let timer: number | null = null;
    return () => {
      if (timer) {
        clearTimeout(timer);
      }
      timer = setTimeout(() => {
        func(); // 【修复】直接调用，不使用 apply
      }, delay);
    };
  }

  /**
   * 节流函数
   * 【修复】同上，移除 any 和 apply
   */
  static throttle(func: () => void, delay: number): () => void {
    let lastCall = 0;
    return () => {
      const now = new Date().getTime();
      if (now - lastCall < delay) {
        return;
      }
      lastCall = now;
      func(); // 【修复】直接调用
    };
  }

  /**
   * 验证邮箱格式
   */
  static isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  /**
   * 验证手机号格式
   */
  static isValidPhone(phone: string): boolean {
    const phoneRegex = /^1[3-9]\d{9}$/;
    return phoneRegex.test(phone);
  }

  /**
   * 生成随机ID
   */
  static generateId(): string {
    return `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * 计算平均分
   */
  static calculateAverage(scores: number[]): number {
    if (!scores || scores.length === 0) return 0;
    const sum = scores.reduce((a, b) => a + b, 0);
    return Number((sum / scores.length).toFixed(2));
  }

  /**
   * 文件大小格式化
   */
  static formatFileSize(bytes: number): string {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }
}