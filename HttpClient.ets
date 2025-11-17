import { promptAction } from '@kit.ArkUI';

/**
 * 手动定义 RequestInit 接口
 */
interface RequestInit {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'HEAD' | 'OPTIONS';
  headers?: Record<string, string>;
  body?: string | ArrayBuffer;
}

/**
 * HTTP 响应接口
 * T = Object 确保类型是显式的
 */
interface HttpResponse<T = Object> {
  ok: boolean;
  status: number;
  statusText: string;
  json(): Promise<T>;
}

/**
 * 全局 fetch 函数声明
 */
declare function fetch(url: string, options?: RequestInit): Promise<HttpResponse>;

/**
 * 错误响应接口
 */
interface ErrorResponse {
  message?: string;
}

/**
 * 封装的 HTTP 客户端，使用 ArkTS 的 fetch API。
 */
export class HttpClient {
  private static instance: HttpClient;
  // 请将此基础 URL 替换为您实际的 API 地址
  private readonly baseUrl: string = 'http://localhost:8081/api/v1/grading';

  private constructor() {}

  static getInstance(): HttpClient {
    if (!HttpClient.instance) {
      HttpClient.instance = new HttpClient();
    }
    return HttpClient.instance;
  }

  /**
   * 封装的请求方法
   * @param path API 路径
   * @param options 请求配置 (包含 method, headers, body 等)
   * @returns Promise<T>
   */
  async request<T>(path: string, options: RequestInit = {}): Promise<T> {
    const url = `${this.baseUrl}${path}`;

    try {
      // 依赖于 ArkTS 环境中全局提供的 fetch API
      const response: HttpResponse = await fetch(url, options);

      if (!response.ok) {
        let errorMessage: string = `HTTP 错误: ${response.status} ${response.statusText}`;
        try {
          // 尝试读取并解析错误信息
          // 修正第70行: 使用类型断言 (as) 替代显式类型注解，避免触发 arkts-no-structural-typing
          const errorBody = await response.json() as ErrorResponse;
          if (errorBody && errorBody.message) {
            errorMessage = errorBody.message;
          }
        } catch (e) {
          // 如果响应体不是 JSON 或无法解析，则忽略
          console.log('无法解析错误响应体');
        }
        // 确保抛出的是 Error 对象
        throw new Error(errorMessage);
      }

      // 假设所有成功的响应都返回 JSON
      return await response.json() as T;

    } catch (error) { // 移除 : unknown 类型注解，符合 arkts-no-types-in-catch 规范
      console.error('网络请求失败:', error);
      let errorMessage: string = '未知错误';

      // 类型安全的错误处理
      if (error instanceof Error) {
        errorMessage = error.message;
      } else if (typeof error === 'string') {
        errorMessage = error;
      }

      // 使用 promptAction 提示用户错误信息
      promptAction.showToast({
        message: `请求失败: ${errorMessage}`,
        duration: 2000
      });
      // 确保 throw 的是 Error 实例，符合 arkts-limited-throw 规范
      throw new Error(errorMessage);
    }
  }

  /**
   * GET 请求
   * @param path API 路径
   * @param params URL 查询参数
   */
  async get<T>(path: string, params?: Record<string, string | number>): Promise<T> {
    let fullPath: string = path;
    if (params) {
      // 拼接查询参数
      const query: string = Object.keys(params)
        .map((key: string): string => `${encodeURIComponent(key)}=${encodeURIComponent(String(params[key]))}`)
        .join('&');
      fullPath = `${path}?${query}`;
    }
    return this.request<T>(fullPath, { method: 'GET' });
  }

  /**
   * POST 请求
   * @param path API 路径
   * @param data 请求体数据
   */
  async post<T>(path: string, data: object): Promise<T> {
    return this.request<T>(path, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });
  }

  /**
   * PUT 请求
   * @param path API 路径
   * @param data 请求体数据
   */
  async put<T>(path: string, data: object): Promise<T> {
    return this.request<T>(path, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });
  }

  /**
   * DELETE 请求
   * @param path API 路径
   */
  async delete<T>(path: string): Promise<T> {
    return this.request<T>(path, { method: 'DELETE' });
  }
}