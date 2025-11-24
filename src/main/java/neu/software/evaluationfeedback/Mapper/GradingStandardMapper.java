// GradingStandardMapper.java
package neu.software.evaluationfeedback.Mapper;

import neu.software.evaluationfeedback.Entity.GradingStandard;
import neu.software.evaluationfeedback.Entity.GradingItem;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface GradingStandardMapper {

    @Select("SELECT * FROM grading_standards WHERE assignment_id = #{assignmentId}")
    GradingStandard findByAssignmentId(Integer assignmentId);

    @Select("SELECT * FROM grading_standards WHERE standard_id = #{standardId}")
    GradingStandard findById(Integer standardId);

    @Insert("INSERT INTO grading_standards (assignment_id, name, total_score, create_time, update_time) " +
            "VALUES (#{assignmentId}, #{name}, #{totalScore}, #{createTime}, #{updateTime})")
    @Options(useGeneratedKeys = true, keyProperty = "standardId")
    int insert(GradingStandard standard);

    @Update("UPDATE grading_standards SET name = #{name}, total_score = #{totalScore}, update_time = #{updateTime} " +
            "WHERE standard_id = #{standardId}")
    int update(GradingStandard standard);

    // GradingItem相关操作
    @Select("SELECT * FROM grading_items WHERE standard_id = #{standardId}")
    List<GradingItem> findItemsByStandardId(Integer standardId);

    @Insert("INSERT INTO grading_items (standard_id, name, description, score, weight) " +
            "VALUES (#{standardId}, #{name}, #{description}, #{score}, #{weight})")
    @Options(useGeneratedKeys = true, keyProperty = "itemId")
    int insertItem(GradingItem item);

    @Update("UPDATE grading_items SET name = #{name}, description = #{description}, score = #{score}, weight = #{weight} " +
            "WHERE item_id = #{itemId}")
    int updateItem(GradingItem item);

    @Delete("DELETE FROM grading_items WHERE item_id = #{itemId}")
    int deleteItem(Integer itemId);

    @Delete("DELETE FROM grading_items WHERE standard_id = #{standardId}")
    int deleteItemsByStandardId(Integer standardId);
}