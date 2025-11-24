import { HttpService } from '../common/HttpService';
import { ApiConfig } from '../common/ApiConfig';

// 后端直接返回的JSON数组项接口
interface SimpleCriterionResponse {
  name: string;
  score: number;
  description?: string;
  weight?: number;
}

// 简化的评分标准格式（用于保存到数据库）
interface SimpleCriterion {
  name: string;
  score: number;
}

// 更新作业的请求数据
interface UpdateAssignmentRequest {
  gradingCriteria: string;
  fullScore: number;
}

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
  name?: string;
  totalScore: number;
  items: GradingItemRequest[];
}

export class GradingStandardService {
  private http = HttpService.getInstance();

  /**
   * 【新增方法】根据 ID 删除单个评分标准项
   * 对应后端: DELETE /api/v1/grading/grading-criteria/{criterionId}
   * @param criterionId 要删除的评分标准项的唯一ID
   * @returns Promise<boolean> 删除是否成功
   */
  async deleteCriterion(criterionId: string): Promise<boolean> {
    try {
      console.log(`[Service] 准备调用后端删除评分标准项: ${criterionId}`);
      console.log(`📌 请求URL: ${ApiConfig.DELETE_CRITERION(criterionId)}`);

      await this.http.delete<void>(ApiConfig.DELETE_CRITERION(criterionId));

      console.log(`✅ 评分标准项 ${criterionId} 删除成功`);
      return true;
    } catch (error) {
      console.error(`❌ 删除评分标准项 ${criterionId} 失败:`, error);
      return false;
    }
  }

  /**
   * 获取作业的评分标准列表
   * 对应后端: GET /api/v1/grading/assignment/{assignmentId}/grading-standard
   */
  async getGradingStandard(assignmentId: string): Promise<GradingCriterion[]> {
    try {
      console.log(`🔍 获取评分标准: assignmentId=${assignmentId}`);
      console.log(`📌 请求URL: ${ApiConfig.GRADING_STANDARD(assignmentId)}`);

      // 后端可能返回两种格式：
      // 1. 直接返回数组: [{"name":"xx","score":30}]
      // 2. 返回对象: {"items": [...]}
      const response = await this.http.get<SimpleCriterionResponse[] | GradingStandardResponse>(
        ApiConfig.GRADING_STANDARD(assignmentId)
      );

      console.log('📦 原始响应数据:', JSON.stringify(response));

      let itemsArray: SimpleCriterionResponse[] | GradingItemResponse[] = [];
      
      // 判断是数组还是对象
      if (Array.isArray(response)) {
        // 情凵1：直接返回数组 [{"name":"xx","score":30}]
        console.log('📦 后端返回的是数组格式');
        itemsArray = response as SimpleCriterionResponse[];
      } else if (response && (response as GradingStandardResponse).items !== undefined) {
        // 情凵2：返回对象 {"items": [...]}
        console.log('📦 后端返回的是对象格式');
        itemsArray = (response as GradingStandardResponse).items;
      } else {
        console.log('⚠️ 未获取到评分标准，返回空数组');
        return [];
      }

      // 将后端的items转换为前端的GradingCriterion数组
      const criteria: GradingCriterion[] = itemsArray.map((item: SimpleCriterionResponse | GradingItemResponse): GradingCriterion => {
        // 判断是SimpleCriterionResponse还是GradingItemResponse
        // SimpleCriterionResponse 有 score 字段，GradingItemResponse 有 itemId 字段
        const asSimple = item as SimpleCriterionResponse;
        const asGrading = item as GradingItemResponse;
        
        const criterion: GradingCriterion = {
          // 使用name作为criterionId（因为后端没有ID）
          criterionId: item.name,
          assignmentId: assignmentId,
          name: item.name,
          description: item.description || '',
          // 优先使用 score 字段
          maxScore: asSimple.score || asGrading.score || 0,
          weight: item.weight ? item.weight * 100 : 0
        };
        return criterion;
      });

      if (criteria.length > 0) {
        console.log(`✅ 成功获取 ${criteria.length} 个评分标准`);
        criteria.forEach((item, index) => {
          console.log(`  [${index}] ${item.name}: ${item.maxScore}分`);
        });
      } else {
        console.log('✅ 后端返回空的评分标准列表，用户可以添加新标准');
      }
      return criteria;
    } catch (error) {
      console.error('❌ 获取评分标准失败:', error);
      return [];
    }
  }

  /**
   * 保存评分标准（批量保存/更新）
   * 直接更新作业的 grading_criteria 字段
   */
  async saveGradingStandard(criteria: GradingCriterion[]): Promise<boolean> {
    try {
      const assignmentId = criteria[0]?.assignmentId || '';
      if (!assignmentId) {
        console.error('❌ 缺少 assignmentId，无法保存');
        return false;
      }
      
      console.log(`💾 保存评分标准: assignmentId=${assignmentId}, ${criteria.length} 个标准`);

      // 构造简化的评分标准数组（直接对应数据库JSON格式）
      const simpleCriteria: SimpleCriterion[] = criteria.map((c: GradingCriterion): SimpleCriterion => {
        const item: SimpleCriterion = {
          name: c.name,
          score: c.maxScore
        };
        return item;
      });

      // 计算总分
      const totalScore = criteria.reduce((sum, c) => sum + c.maxScore, 0);
      
      // 构造更新作业的请求数据
      const updateData: UpdateAssignmentRequest = {
        gradingCriteria: JSON.stringify(simpleCriteria),
        fullScore: totalScore
      };

      console.log('📦 发送数据:', JSON.stringify(updateData));

      // 使用 PUT 请求更新作业
      await this.http.put<void>(
        ApiConfig.UPDATE_ASSIGNMENT(assignmentId),
        updateData
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