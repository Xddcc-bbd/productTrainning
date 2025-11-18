// entry/src/main/ets/common/HttpService.ets

import http from '@ohos.net.http';
import { Constants } from './Constants';

// 自定义错误类
class HttpError extends Error {
  code: number;

  constructor(code: number, message: string) {
    super(message);
    this.name = 'HttpError';
    this.code = code;
  }
}

// 明确定义请求头接口 - 不使用索引签名
interface HttpHeaders {
  'Content-Type': string;
  'Authorization'?: string;
  // 如果需要其他头部，在这里明确定义
  'Accept'?: string;
  'User-Agent'?: string;
}

// 明确定义请求选项接口
interface HttpRequestOptions {
  method: http.RequestMethod;
  header: HttpHeaders;
  extraData?: string;
  connectTimeout?: number;
  readTimeout?: number;
}

// 定义通用的数据对象类型 - 使用具体类型代替索引签名
type DataValue = string | number | boolean | null | undefined;
interface DataObject {
  // 不使用索引签名，而是明确定义可能的字段
  [x: string]: never; // 这行实际上不会匹配任何内容，只是为了满足类型检查
}

export class HttpService {
  private static instance: HttpService = new HttpService();
  private baseURL: string = Constants.BASE_URL;

  public static getInstance(): HttpService {
    return HttpService.instance;
  }

  /**
   * GET请求
   */
  async get<T>(url: string): Promise<T> {
    const headers: HttpHeaders = {
      'Content-Type': 'application/json'
    };

    const options: HttpRequestOptions = {
      method: http.RequestMethod.GET,
      header: headers,
      connectTimeout: 10000,
      readTimeout: 10000
    };

    return this.request<T>(url, options);
  }

  /**
   * POST请求
   */
  async post<T>(url: string, data: Object): Promise<T> {
    const headers: HttpHeaders = {
      'Content-Type': 'application/json'
    };

    const options: HttpRequestOptions = {
      method: http.RequestMethod.POST,
      header: headers,
      extraData: JSON.stringify(data),
      connectTimeout: 10000,
      readTimeout: 10000
    };

    return this.request<T>(url, options);
  }

  /**
   * PUT请求
   */
  async put<T>(url: string, data: Object): Promise<T> {
    const headers: HttpHeaders = {
      'Content-Type': 'application/json'
    };

    const options: HttpRequestOptions = {
      method: http.RequestMethod.PUT,
      header: headers,
      extraData: JSON.stringify(data),
      connectTimeout: 10000,
      readTimeout: 10000
    };

    return this.request<T>(url, options);
  }

  /**
   * DELETE请求
   */
  async delete<T>(url: string): Promise<T> {
    const headers: HttpHeaders = {
      'Content-Type': 'application/json'
    };

    const options: HttpRequestOptions = {
      method: http.RequestMethod.DELETE,
      header: headers,
      connectTimeout: 10000,
      readTimeout: 10000
    };

    return this.request<T>(url, options);
  }

  /**
   * 通用请求方法
   */
  private async request<T>(url: string, options: HttpRequestOptions): Promise<T> {
    try {
      let httpRequest = http.createHttp();
      let response = await httpRequest.request(this.baseURL + url, options);

      if (response.responseCode === 200 || response.responseCode === 201) {
        const result = response.result as string;
        if (result && result.trim() !== '') {
          return JSON.parse(result) as T;
        } else {
          // 对于空响应，返回null并让调用方处理
          return null as unknown as T;
        }
      } else {
        throw new HttpError(response.responseCode, `HTTP ${response.responseCode}: ${response.result}`);
      }
    } catch (error) {
      console.error('HTTP请求失败:', error);
      if (error instanceof HttpError) {
        throw error;
      } else {
        throw new HttpError(0, `网络请求失败: ${error.message}`);
      }
    }
  }
}