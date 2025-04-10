/// 元素状态枚举
/// 
/// 描述元素在解析和渲染过程中的状态
enum ElementState {
  creating,          // 正在创建中
  complete,          // 已完成创建
  invalidated,       // 已失效需要更新
  error,             // 解析错误
} 