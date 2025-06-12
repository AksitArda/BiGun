import 'package:bigun/models/story.dart';
import 'dart:async';

class StoryRepository {
  static final StoryRepository _instance = StoryRepository._internal();
  factory StoryRepository() => _instance;
  StoryRepository._internal();

  final _storyController = StreamController<List<Story>>.broadcast();
  final List<Story> _stories = [];
  
  Stream<List<Story>> get stories => _storyController.stream;
  
  Future<void> addStory(Story story) async {
    try {
      _stories.insert(0, story);
      _storyController.add(_stories);
      await _uploadStory(story);
    } catch (e) {
      print('Error adding story: $e');
      _stories.remove(story);
      _storyController.add(_stories);
      rethrow;
    }
  }
  
  Future<void> _uploadStory(Story story) async {
    // TODO: Implement actual API call
    await Future.delayed(Duration(seconds: 1));
  }
  
  Future<List<Story>> fetchStories({int page = 0, int limit = 10}) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(Duration(seconds: 1));
      return _stories;
    } catch (e) {
      print('Error fetching stories: $e');
      rethrow;
    }
  }
  
  Future<void> deleteStory(String storyId) async {
    try {
      _stories.removeWhere((story) => story.id == storyId);
      _storyController.add(_stories);
      await _deleteStoryFromServer(storyId);
    } catch (e) {
      print('Error deleting story: $e');
      rethrow;
    }
  }
  
  Future<void> _deleteStoryFromServer(String storyId) async {
    // TODO: Implement actual API call
    await Future.delayed(Duration(seconds: 1));
  }
  
  void dispose() {
    _storyController.close();
  }
} 