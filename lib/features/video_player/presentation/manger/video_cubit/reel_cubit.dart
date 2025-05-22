import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'package:reelsvtwo/models/video_model.dart';
import 'package:reelsvtwo/reel_repo.dart';

@immutable
abstract class ReelState {}

class ReelInitial extends ReelState {}

class ReelLoading extends ReelState {}

class ReelLoadingMore extends ReelState {
  final List<ReelModel> reels;

  ReelLoadingMore(this.reels);
}

class ReelLoaded extends ReelState {
  final List<ReelModel> reels;

  ReelLoaded(this.reels);
}

class ReelError extends ReelState {
  final String message;

  ReelError(this.message);
}

class ReelCubit extends Cubit<ReelState> {
  final ReelRepository _reelRepository;

  ReelCubit({ReelRepository? reelRepository})
    : _reelRepository = reelRepository ?? ReelRepository(),
      super(ReelInitial());

  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMoreData = true;

  Future<void> getReels({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMoreData = true;
        emit(ReelInitial());
      }

      if (!_hasMoreData) return;

      if (state is! ReelLoaded || refresh) {
        emit(ReelLoading());
      } else {
        emit(ReelLoadingMore((state as ReelLoaded).reels));
      }

      final result = await _reelRepository.getReels(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (result.isSuccess && result.data != null) {
        final reelResponse = result.data!;
        final newReels = reelResponse.data;

        // Check if we've reached the end of the data
        if (newReels.length < _pageSize) {
          _hasMoreData = false;
        }

        List<ReelModel> updatedReels = [];
        if (state is ReelLoaded && !refresh) {
          updatedReels = [...(state as ReelLoaded).reels, ...newReels];
        } else {
          updatedReels = newReels;
        }

        _currentPage++;
        emit(ReelLoaded(updatedReels));
      } else {
        emit(ReelError(result.error ?? 'Failed to load reels'));
      }
    } catch (e) {
      emit(ReelError(e.toString()));
    }
  }

  // Convert ReelModels to VideoModels for compatibility with existing player
  List<VideoModel> getReelsAsVideoModels() {
    if (state is ReelLoaded) {
      return (state as ReelLoaded).reels
          .map((reel) => reel.toVideoModel())
          .toList();
    }
    return [];
  }
}
