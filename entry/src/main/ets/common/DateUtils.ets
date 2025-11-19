// entry/src/main/ets/common/DateUtils.ets

/**
 * 日期工具类
 * 处理后端返回的ISO格式时间戳
 */
export class DateUtils {
  /**
   * 将ISO格式时间字符串转换为本地显示格式
   * @param isoString ISO格式时间字符串，如 "2024-08-31T16:00:00.000+00:00"
   * @param format 格式化模板，默认 "YYYY-MM-DD HH:mm:ss"
   * @returns 格式化后的时间字符串
   */
  static formatISODate(isoString: string, format: string = 'YYYY-MM-DD HH:mm:ss'): string {
    if (!isoString) return '';
    
    try {
      const date = new Date(isoString);
      
      if (format === 'YYYY-MM-DD HH:mm:ss') {
        return DateUtils.toLocalString(date);
      } else if (format === 'YYYY-MM-DD') {
        return DateUtils.toDateString(date);
      } else if (format === 'HH:mm:ss') {
        return DateUtils.toTimeString(date);
      }
      
      return DateUtils.toLocalString(date);
    } catch (error) {
      console.error('日期格式化错误:', error);
      return isoString;
    }
  }

  /**
   * 转换为 YYYY-MM-DD HH:mm:ss 格式
   */
  private static toLocalString(date: Date): string {
    const year = date.getFullYear();
    const month = DateUtils.padZero(date.getMonth() + 1);
    const day = DateUtils.padZero(date.getDate());
    const hours = DateUtils.padZero(date.getHours());
    const minutes = DateUtils.padZero(date.getMinutes());
    const seconds = DateUtils.padZero(date.getSeconds());
    
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
  }

  /**
   * 转换为 YYYY-MM-DD 格式
   */
  private static toDateString(date: Date): string {
    const year = date.getFullYear();
    const month = DateUtils.padZero(date.getMonth() + 1);
    const day = DateUtils.padZero(date.getDate());
    
    return `${year}-${month}-${day}`;
  }

  /**
   * 转换为 HH:mm:ss 格式
   */
  private static toTimeString(date: Date): string {
    const hours = DateUtils.padZero(date.getHours());
    const minutes = DateUtils.padZero(date.getMinutes());
    const seconds = DateUtils.padZero(date.getSeconds());
    
    return `${hours}:${minutes}:${seconds}`;
  }

  /**
   * 数字补零
   */
  private static padZero(num: number): string {
    return num < 10 ? `0${num}` : `${num}`;
  }

  /**
   * 计算时间差（友好显示）
   * @param isoString ISO格式时间字符串
   * @returns 友好的时间差显示，如 "3天前"、"2小时前"
   */
  static getTimeAgo(isoString: string): string {
    if (!isoString) return '';
    
    try {
      const date = new Date(isoString);
      const now = new Date();
      const diff = now.getTime() - date.getTime();
      
      const minutes = Math.floor(diff / (1000 * 60));
      const hours = Math.floor(diff / (1000 * 60 * 60));
      const days = Math.floor(diff / (1000 * 60 * 60 * 24));
      
      if (minutes < 1) {
        return '刚刚';
      } else if (minutes < 60) {
        return `${minutes}分钟前`;
      } else if (hours < 24) {
        return `${hours}小时前`;
      } else if (days < 7) {
        return `${days}天前`;
      } else {
        return DateUtils.toDateString(date);
      }
    } catch (error) {
      console.error('计算时间差错误:', error);
      return '';
    }
  }

  /**
   * 计算剩余时间
   * @param endTimeISO 截止时间的ISO格式字符串
   * @returns 剩余时间的友好显示
   */
  static getRemainingTime(endTimeISO: string): string {
    if (!endTimeISO) return '';
    
    try {
      const endTime = new Date(endTimeISO);
      const now = new Date();
      const diff = endTime.getTime() - now.getTime();
      
      if (diff <= 0) return '已截止';
      
      const days = Math.floor(diff / (1000 * 60 * 60 * 24));
      const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
      
      if (days > 0) {
        return `剩余${days}天${hours}小时`;
      } else if (hours > 0) {
        return `剩余${hours}小时${minutes}分钟`;
      } else {
        return `剩余${minutes}分钟`;
      }
    } catch (error) {
      console.error('计算剩余时间错误:', error);
      return '';
    }
  }

  /**
   * 判断是否已截止
   */
  static isExpired(endTimeISO: string): boolean {
    if (!endTimeISO) return false;
    
    try {
      const endTime = new Date(endTimeISO);
      const now = new Date();
      return now.getTime() > endTime.getTime();
    } catch (error) {
      return false;
    }
  }
}
