// entry/src/main/ets/service/GradingStandardService.ets

import { HttpService } from '../common/HttpService';
import { ApiConfig } from '../common/ApiConfig';

// 评分标准接口
export interface GradingCriterion {
  criterionId?: string;
  assignmentId: string;
  name: string;
  description: string;
  maxScore: number;
  weight: number;
  createdTime?: string;
}

// 后端返回的评分项接口
interface GradingItemResponse {
  itemId?: number;
  standardId?: number;
  name: string;
  description: string;
  score: number;
  weight: number;
}

// 后端返回的评分标准响应接口
interface GradingStandardResponse {
  standardId?: number;
  assignmentId: string;
  name?: string;
  totalScore: number;
  createTime?: string;
  updateTime?: string;
  items: GradingItemResponse[];
}

// 保存评分标准时的评分项数据
interface GradingItemRequest {
  itemId?: string;
  name: string;
  description: string;
  score: number;
  weight: number;
}

// 保存评分标准请求接口
interface SaveGradingStandardRequest {
  assignmentId: string;
  totalScore: number;
  items: GradingItemRequest[];
}

export class GradingStandardService {
  private http = HttpService.getInstance();

  /**
   * 获取作业的评分标准列表
   * 对应后端: GET /api/v1/grading/assignment/{assignmentId}/grading-standard
   * 后端返回的数据结构：
   * {
   *   standardId: 1,
   *   assignmentId: "1",
   *   totalScore: 100,
   *   items: [
   *     { itemId: 1, name: "...", description: "...", score: 30, weight: 0.3 }
   *   ]
   * }
   */
  async getGradingStandard(assignmentId: string): Promise<GradingCriterion[]> {
    try {
      console.log(`🔍 获取评分标准: assignmentId=${assignmentId}`);
      console.log(`📌 请求URL: ${ApiConfig.GRADING_STANDARD(assignmentId)}`);
      
      const response = await this.http.get<GradingStandardResponse>(
        ApiConfig.GRADING_STANDARD(assignmentId)
      );
      
      console.log('📦 原始响应数据:', JSON.stringify(response));
      
      // 后端返回的是一个对象，包含items数组
      if (response && response.items && response.items.length > 0) {
        // 将后端的items转换为前端的GradingCriterion数组
        const criteria: GradingCriterion[] = response.items.map((item: GradingItemResponse) => {
          const criterion: GradingCriterion = {
            criterionId: item.itemId ? item.itemId.toString() : undefined,
            assignmentId: assignmentId,
            name: item.name,
            description: item.description,
            maxScore: item.score,
            weight: item.weight * 100
          };
          return criterion;
        });
        
        console.log(`✅ 成功获取 ${criteria.length} 个评分标准`);
        // 打印每一项的详细信息
        criteria.forEach((item, index) => {
          console.log(`  [${index}] ${item.name}: ${item.maxScore}分, ${item.weight}%, ${item.description}`);
        });
        return criteria;
      }
      
      console.log('⚠️ 未获取到评分标准，返回空数组');
      return [];
    } catch (error) {
      console.error('❌ 获取评分标准失败:', error);
      return [];
    }
  }

  /**
   * 保存评分标准（批量保存）
   * 对应后端: POST /api/v1/grading/grading-standard
   * 后端期期待的数据结构：
   * {
   *   assignmentId: "1",
   *   totalScore: 100,
   *   items: [
   *     { name: "...", description: "...", score: 30, weight: 0.3 }
   *   ]
   * }
   */
  async saveGradingStandard(criteria: GradingCriterion[]): Promise<boolean> {
    try {
      if (criteria.length === 0) {
        console.log('⚠️ 没有评分标准需要保存');
        return true;
      }
      
      const assignmentId = criteria[0].assignmentId;
      console.log(`💾 保存评分标准: assignmentId=${assignmentId}, ${criteria.length} 个标准`);
      
      // 构造后端期期待的数据结构
      const requestData: SaveGradingStandardRequest = {
        assignmentId: assignmentId,
        totalScore: 100,
        items: criteria.map(c => {
          const item: GradingItemRequest = {
            itemId: c.criterionId,
            name: c.name,
            description: c.description,
            score: c.maxScore,
            weight: c.weight / 100
          };
          return item;
        })
      };
      
      console.log('📦 发送数据:', JSON.stringify(requestData));
      
      await this.http.post<void>(
        ApiConfig.SAVE_GRADING_STANDARD,
        requestData
      );
      console.log('✅ 评分标准保存成功');
      return true;
    } catch (error) {
      console.error('❌ 保存评分标准失败:', error);
      return false;
    }
  }
}

export const gradingStandardService = new GradingStandardService();
