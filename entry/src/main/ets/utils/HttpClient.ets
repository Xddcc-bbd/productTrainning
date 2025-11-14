import { promptAction } from '@kit.ArkUI';
// 移除了 'import { net } from '@kit.NetworkKit';' 这一行，以解决 Module '"@kit.NetworkKit"' has no exported member 'net' 的错误。

/**
 * 手动定义 RequestInit 接口，以解决 'Cannot find name RequestInit' 的报错。
 * 在 ArkTS/OpenHarmony 环境中，用于表示二进制数据的是 ArrayBuffer，因此移除 Blob。
 */
interface RequestInit {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'HEAD' | 'OPTIONS';
  headers?: Record<string, string>;
  // body 类型修正为 string 或 ArrayBuffer
  body?: string | ArrayBuffer;
  // 可以根据实际需要添加其他 fetch 选项
}

/**
 * 封装的 HTTP 客户端，使用 ArkTS 的 fetch API。
 */
export class HttpClient {
  private static instance: HttpClient;
  // 请将此基础 URL 替换为您实际的 API 地址
  private readonly baseUrl: string = 'http://your-api-server.com';

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
      const response = await fetch(url, options);

      if (!response.ok) {
        let errorMessage = `HTTP 错误: ${response.status} ${response.statusText}`;
        try {
          // 尝试读取并解析错误信息
          const errorBody = await response.json();
          if (errorBody && errorBody.message) {
            errorMessage = errorBody.message;
          }
        } catch (e) {
          // 如果响应体不是 JSON 或无法解析，则忽略
        }
        throw new Error(errorMessage);
      }

      // 假设所有成功的响应都返回 JSON
      return await response.json() as T;

    } catch (error) {
      console.error('网络请求失败:', error);
      // 使用 promptAction 提示用户错误信息
      promptAction.showToast({
        message: `请求失败: ${error.message || '未知错误'}`,
        duration: 2000
      });
      // 抛出错误以供调用方处理
      throw error;
    }
  }

  /**
   * GET 请求
   * @param path API 路径
   * @param params URL 查询参数
   */
  async get<T>(path: string, params?: Record<string, string | number>): Promise<T> {
    let fullPath = path;
    if (params) {
      // 拼接查询参数
      const query = Object.keys(params)
        .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(String(params[key]))}`)
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
  async post<T>(path: string, data: any): Promise<T> {
    return this.request<T>(path, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });
  }

  // 您可以添加 put, delete 等其他方法...
}