import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:ui';
import '../../config/theme.dart';

enum LoadingStyle {
  modern,     // 글래스모피즘 스타일
  minimal,    // 미니멀 스타일
  floating,   // 플로팅 버블 스타일
  gradient,   // 그라데이션 스타일
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? backgroundColor;
  final Color? spinnerColor;
  final LoadingStyle style;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.backgroundColor,
    this.spinnerColor,
    this.style = LoadingStyle.modern,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.4),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Center(
                child: _buildLoadingDialog(context),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingDialog(BuildContext context) {
    switch (style) {
      case LoadingStyle.modern:
        return _buildModernLoading(context);
      case LoadingStyle.minimal:
        return _buildMinimalLoading(context);
      case LoadingStyle.floating:
        return _buildFloatingLoading(context);
      case LoadingStyle.gradient:
        return _buildGradientLoading(context);
    }
  }

  Widget _buildModernLoading(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.secondaryColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SpinKitPulsingGrid(
              color: spinnerColor ?? AppTheme.primaryColor,
              size: 50,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 20),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMinimalLoading(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SpinKitRipple(
        color: spinnerColor ?? AppTheme.primaryColor,
        size: 60,
      ),
    );
  }

  Widget _buildFloatingLoading(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.secondaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 5,
              ),
            ],
          ),
          child: SpinKitWave(
            color: Colors.white,
            size: 30,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGradientLoading(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.9),
            AppTheme.secondaryColor.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitDoubleBounce(
            color: Colors.white,
            size: 50,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;
  final LoadingStyle style;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
    this.size = 50,
    this.style = LoadingStyle.modern,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildLoadingContent(context),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    switch (style) {
      case LoadingStyle.modern:
        return _buildModernContent(context);
      case LoadingStyle.minimal:
        return _buildMinimalContent(context);
      case LoadingStyle.floating:
        return _buildFloatingContent(context);
      case LoadingStyle.gradient:
        return _buildGradientContent(context);
    }
  }

  Widget _buildModernContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (color ?? AppTheme.primaryColor).withOpacity(0.1),
                AppTheme.secondaryColor.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SpinKitPulsingGrid(
            color: color ?? AppTheme.primaryColor,
            size: size,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildMinimalContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SpinKitRipple(
          color: color ?? AppTheme.primaryColor,
          size: size,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildFloatingContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SpinKitWave(
          color: color ?? AppTheme.primaryColor,
          size: size * 0.6,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildGradientContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SpinKitDoubleBounce(
          color: color ?? AppTheme.primaryColor,
          size: size,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// 인라인 로딩 인디케이터 (버튼 내부 등에서 사용)
class InlineLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;
  final LoadingStyle style;

  const InlineLoadingIndicator({
    super.key,
    this.color,
    this.size = 20,
    this.style = LoadingStyle.minimal,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case LoadingStyle.modern:
        return SpinKitPulse(
          color: color ?? Colors.white,
          size: size,
        );
      case LoadingStyle.minimal:
        return SpinKitThreeBounce(
          color: color ?? Colors.white,
          size: size,
        );
      case LoadingStyle.floating:
        return SpinKitWave(
          color: color ?? Colors.white,
          size: size * 0.8,
        );
      case LoadingStyle.gradient:
        return SpinKitFadingFour(
          color: color ?? Colors.white,
          size: size,
        );
    }
  }
}

/// 풀스크린 로딩 (스플래시 등에서 사용)
class FullScreenLoading extends StatelessWidget {
  final String? message;
  final String? subtitle;
  final Widget? logo;
  final LoadingStyle style;

  const FullScreenLoading({
    super.key,
    this.message,
    this.subtitle,
    this.logo,
    this.style = LoadingStyle.modern,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (logo != null) ...[
                logo!,
                const SizedBox(height: 48),
              ],
              _buildFullScreenContent(context),
              if (subtitle != null) ...[
                const SizedBox(height: 24),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: _getFullScreenSpinner(),
        ),
        if (message != null) ...[
          const SizedBox(height: 24),
          Text(
            message!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _getFullScreenSpinner() {
    switch (style) {
      case LoadingStyle.modern:
        return SpinKitPulsingGrid(
          color: Colors.white,
          size: 60,
        );
      case LoadingStyle.minimal:
        return SpinKitRipple(
          color: Colors.white,
          size: 80,
        );
      case LoadingStyle.floating:
        return SpinKitWave(
          color: Colors.white,
          size: 40,
        );
      case LoadingStyle.gradient:
        return SpinKitDoubleBounce(
          color: Colors.white,
          size: 60,
        );
    }
  }
}