import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/recipe.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/common/custom_icon_button.dart';

class RecipeEditScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeEditScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends State<RecipeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tipsController;
  late TextEditingController _servingsController;
  late TextEditingController _cookingTimeController;
  
  List<TextEditingController> _ingredientNameControllers = [];
  List<TextEditingController> _ingredientAmountControllers = [];
  List<TextEditingController> _ingredientNotesControllers = [];
  
  List<TextEditingController> _stepControllers = [];
  List<TextEditingController> _stepTimeControllers = [];
  List<TextEditingController> _stepTemperatureControllers = [];
  List<TextEditingController> _stepTipsControllers = [];
  
  String _selectedDifficulty = '보통';
  String _selectedCategory = '기타';
  bool _isLoading = false;

  final List<String> _difficultyOptions = ['쉬움', '보통', '어려움'];
  final List<String> _categoryOptions = ['한식', '중식', '일식', '양식', '디저트', '음료', '기타'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.recipe.title);
    _descriptionController = TextEditingController(text: widget.recipe.description ?? '');
    _tipsController = TextEditingController(text: widget.recipe.tips ?? '');
    _servingsController = TextEditingController(text: widget.recipe.servings ?? '');
    _cookingTimeController = TextEditingController(text: widget.recipe.cookingTime ?? '');
    
    _selectedDifficulty = widget.recipe.difficulty ?? '보통';
    _selectedCategory = widget.recipe.category ?? '기타';

    // 재료 컨트롤러 초기화
    if (widget.recipe.ingredients != null) {
      for (var ingredient in widget.recipe.ingredients!) {
        _ingredientNameControllers.add(TextEditingController(text: ingredient.name));
        _ingredientAmountControllers.add(TextEditingController(text: ingredient.amount));
        _ingredientNotesControllers.add(TextEditingController(text: ingredient.notes ?? ''));
      }
    }
    
    // 최소 하나는 있어야 함
    if (_ingredientNameControllers.isEmpty) {
      _addIngredient();
    }

    // 조리 단계 컨트롤러 초기화
    if (widget.recipe.steps != null) {
      for (var step in widget.recipe.steps!) {
        _stepControllers.add(TextEditingController(text: step.instruction));
        _stepTimeControllers.add(TextEditingController(text: step.time ?? ''));
        _stepTemperatureControllers.add(TextEditingController(text: step.temperature ?? ''));
        _stepTipsControllers.add(TextEditingController(text: step.tips ?? ''));
      }
    }
    
    // 최소 하나는 있어야 함
    if (_stepControllers.isEmpty) {
      _addStep();
    }
  }

  void _disposeControllers() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tipsController.dispose();
    _servingsController.dispose();
    _cookingTimeController.dispose();
    
    for (var controller in _ingredientNameControllers) {
      controller.dispose();
    }
    for (var controller in _ingredientAmountControllers) {
      controller.dispose();
    }
    for (var controller in _ingredientNotesControllers) {
      controller.dispose();
    }
    
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    for (var controller in _stepTimeControllers) {
      controller.dispose();
    }
    for (var controller in _stepTemperatureControllers) {
      controller.dispose();
    }
    for (var controller in _stepTipsControllers) {
      controller.dispose();
    }
  }

  bool get _hasChanges {
    // 기본 정보 변경 확인
    if (_titleController.text != widget.recipe.title ||
        _descriptionController.text != (widget.recipe.description ?? '') ||
        _tipsController.text != (widget.recipe.tips ?? '') ||
        _servingsController.text != (widget.recipe.servings ?? '') ||
        _cookingTimeController.text != (widget.recipe.cookingTime ?? '') ||
        _selectedDifficulty != (widget.recipe.difficulty ?? '보통') ||
        _selectedCategory != (widget.recipe.category ?? '기타')) {
      return true;
    }
    
    // 재료 변경 확인
    if (_ingredientNameControllers.length != (widget.recipe.ingredients?.length ?? 0)) {
      return true;
    }
    
    for (int i = 0; i < _ingredientNameControllers.length; i++) {
      if (i < (widget.recipe.ingredients?.length ?? 0)) {
        final ingredient = widget.recipe.ingredients![i];
        if (_ingredientNameControllers[i].text != ingredient.name ||
            _ingredientAmountControllers[i].text != ingredient.amount ||
            _ingredientNotesControllers[i].text != (ingredient.notes ?? '')) {
          return true;
        }
      }
    }
    
    // 조리 단계 변경 확인
    if (_stepControllers.length != (widget.recipe.steps?.length ?? 0)) {
      return true;
    }
    
    for (int i = 0; i < _stepControllers.length; i++) {
      if (i < (widget.recipe.steps?.length ?? 0)) {
        final step = widget.recipe.steps![i];
        if (_stepControllers[i].text != step.instruction ||
            _stepTimeControllers[i].text != (step.time ?? '') ||
            _stepTemperatureControllers[i].text != (step.temperature ?? '') ||
            _stepTipsControllers[i].text != (step.tips ?? '')) {
          return true;
        }
      }
    }
    
    return false;
  }

  void _addIngredient() {
    setState(() {
      _ingredientNameControllers.add(TextEditingController());
      _ingredientAmountControllers.add(TextEditingController());
      _ingredientNotesControllers.add(TextEditingController());
    });
  }

  void _removeIngredient(int index) {
    if (_ingredientNameControllers.length > 1) {
      setState(() {
        _ingredientNameControllers[index].dispose();
        _ingredientAmountControllers[index].dispose();
        _ingredientNotesControllers[index].dispose();
        
        _ingredientNameControllers.removeAt(index);
        _ingredientAmountControllers.removeAt(index);
        _ingredientNotesControllers.removeAt(index);
      });
    }
  }

  void _addStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
      _stepTimeControllers.add(TextEditingController());
      _stepTemperatureControllers.add(TextEditingController());
      _stepTipsControllers.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    if (_stepControllers.length > 1) {
      setState(() {
        _stepControllers[index].dispose();
        _stepTimeControllers[index].dispose();
        _stepTemperatureControllers[index].dispose();
        _stepTipsControllers[index].dispose();
        
        _stepControllers.removeAt(index);
        _stepTimeControllers.removeAt(index);
        _stepTemperatureControllers.removeAt(index);
        _stepTipsControllers.removeAt(index);
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 재료 리스트 생성
      final ingredients = <RecipeIngredient>[];
      for (int i = 0; i < _ingredientNameControllers.length; i++) {
        final name = _ingredientNameControllers[i].text.trim();
        final amount = _ingredientAmountControllers[i].text.trim();
        if (name.isNotEmpty && amount.isNotEmpty) {
          ingredients.add(RecipeIngredient(
            name: name,
            amount: amount,
            notes: _ingredientNotesControllers[i].text.trim().isNotEmpty 
                ? _ingredientNotesControllers[i].text.trim() 
                : null,
          ));
        }
      }

      // 조리 단계 리스트 생성
      final steps = <RecipeStep>[];
      for (int i = 0; i < _stepControllers.length; i++) {
        final instruction = _stepControllers[i].text.trim();
        if (instruction.isNotEmpty) {
          steps.add(RecipeStep(
            step: i + 1,
            instruction: instruction,
            time: _stepTimeControllers[i].text.trim().isNotEmpty 
                ? _stepTimeControllers[i].text.trim() 
                : null,
            temperature: _stepTemperatureControllers[i].text.trim().isNotEmpty 
                ? _stepTemperatureControllers[i].text.trim() 
                : null,
            tips: _stepTipsControllers[i].text.trim().isNotEmpty 
                ? _stepTipsControllers[i].text.trim() 
                : null,
          ));
        }
      }

      final updatedRecipe = widget.recipe.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        ingredients: ingredients,
        steps: steps,
        tips: _tipsController.text.trim().isNotEmpty 
            ? _tipsController.text.trim() 
            : null,
        servings: _servingsController.text.trim().isNotEmpty 
            ? _servingsController.text.trim() 
            : null,
        cookingTime: _cookingTimeController.text.trim().isNotEmpty 
            ? _cookingTimeController.text.trim() 
            : null,
        difficulty: _selectedDifficulty,
        category: _selectedCategory,
        updatedAt: DateTime.now(),
      );

      final success = await context.read<RecipeProvider>().updateRecipe(updatedRecipe);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('레시피가 성공적으로 수정되었습니다! 🎉'),
              backgroundColor: AppTheme.primaryColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, updatedRecipe);
        }
      } else {
        if (mounted) {
          final errorMessage = context.read<RecipeProvider>().errorMessage ?? '레시피 수정에 실패했습니다.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('변경사항이 있습니다'),
        content: const Text('저장하지 않고 나가시겠습니까?\n변경사항이 모두 사라집니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('나가기'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBasicInfo(),
                          const SizedBox(height: 24),
                          _buildIngredients(),
                          const SizedBox(height: 24),
                          _buildSteps(),
                          const SizedBox(height: 24),
                          _buildAdditionalInfo(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CustomIconButton(
            icon: Icons.arrow_back,
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '레시피 수정',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          CustomIconButton(
            icon: _isLoading ? Icons.hourglass_empty : Icons.check,
            onPressed: _isLoading ? null : _saveRecipe,
            backgroundColor: _hasChanges ? AppTheme.primaryColor : Colors.grey.shade300,
            iconColor: _hasChanges ? Colors.white : Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기본 정보',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '레시피 이름 *',
              hintText: '예: 엄마의 김치찌개',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '레시피 이름을 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '레시피 설명',
              hintText: '이 레시피에 대한 간단한 설명을 입력해주세요',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _servingsController,
                  decoration: const InputDecoration(
                    labelText: '인분',
                    hintText: '예: 2-3인분',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cookingTimeController,
                  decoration: const InputDecoration(
                    labelText: '조리시간',
                    hintText: '예: 30분',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDifficulty,
                  decoration: const InputDecoration(
                    labelText: '난이도',
                    border: OutlineInputBorder(),
                  ),
                  items: _difficultyOptions.map((String difficulty) {
                    return DropdownMenuItem<String>(
                      value: difficulty,
                      child: Text(difficulty),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedDifficulty = newValue;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: '카테고리',
                    border: OutlineInputBorder(),
                  ),
                  items: _categoryOptions.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredients() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '재료',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              IconButton(
                onPressed: _addIngredient,
                icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
                tooltip: '재료 추가',
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_ingredientNameControllers.length, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _ingredientNameControllers[index],
                          decoration: const InputDecoration(
                            labelText: '재료명 *',
                            hintText: '예: 돼지고기',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '재료명을 입력해주세요';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _ingredientAmountControllers[index],
                          decoration: const InputDecoration(
                            labelText: '양 *',
                            hintText: '300g',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '양을 입력해주세요';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _removeIngredient(index),
                        icon: Icon(
                          Icons.remove_circle,
                          color: _ingredientNameControllers.length > 1 
                              ? AppTheme.errorColor 
                              : Colors.grey,
                        ),
                        tooltip: '재료 삭제',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ingredientNotesControllers[index],
                    decoration: const InputDecoration(
                      labelText: '메모 (선택사항)',
                      hintText: '예: 잘게 썰어주세요',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSteps() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '조리 순서',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              IconButton(
                onPressed: _addStep,
                icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
                tooltip: '단계 추가',
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_stepControllers.length, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${index + 1}단계',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _removeStep(index),
                        icon: Icon(
                          Icons.remove_circle,
                          color: _stepControllers.length > 1 
                              ? AppTheme.errorColor 
                              : Colors.grey,
                        ),
                        tooltip: '단계 삭제',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _stepControllers[index],
                    decoration: const InputDecoration(
                      labelText: '조리 방법 *',
                      hintText: '예: 팬에 기름을 두르고 고기를 볶아주세요',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '조리 방법을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _stepTimeControllers[index],
                          decoration: const InputDecoration(
                            labelText: '소요시간',
                            hintText: '예: 5분',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _stepTemperatureControllers[index],
                          decoration: const InputDecoration(
                            labelText: '온도',
                            hintText: '예: 중불',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _stepTipsControllers[index],
                    decoration: const InputDecoration(
                      labelText: '팁 (선택사항)',
                      hintText: '이 단계에서 주의할 점이나 팁을 적어보세요',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '추가 정보',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _tipsController,
            decoration: const InputDecoration(
              labelText: '요리 팁',
              hintText: '이 레시피에 대한 전체적인 팁이나 변형 방법을 적어보세요',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}